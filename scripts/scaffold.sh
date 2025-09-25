# Create folders
mkdir -p force-app/main/default/{classes,staticresources,promptTemplates,flows,genAiFunctions,genAiPlannerBundles,genAiPlugins,permissionsets}
mkdir -p scripts data fixtures docs manifest .github/workflows
mkdir -p force-app/main/default/classes/tests
mkdir -p force-app/main/default/staticresources/llm_contracts
mkdir -p force-app/main/default/staticresources/meeting_fixtures

# -------------------------------
# JSON Schemas (LLM I/O contract)
# -------------------------------
cat > force-app/main/default/staticresources/llm_contracts/io_contracts.json << 'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:agentforce:io-contracts",
  "title": "Agentforce LLM I/O Contracts",
  "type": "object",
  "properties": {
    "input": {
      "type": "object",
      "required": ["schema_slice", "goal", "constraints"],
      "properties": {
        "schema_slice": { "type": "object" },
        "goal": { "type": "string", "minLength": 1 },
        "constraints": { "type": "object" }
      },
      "additionalProperties": false
    },
    "output": {
      "type": "object",
      "required": ["plan", "code_artifacts"],
      "properties": {
        "plan": {
          "type": "object",
          "required": ["capabilities", "steps", "actions", "dependencies", "checkpoint_text"],
          "properties": {
            "capabilities": { "type": "array", "items": { "type": "string" } },
            "steps": { "type": "array", "items": { "type": "string" } },
            "actions": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["name", "type", "object", "fields", "guardrails"],
                "properties": {
                  "name": { "type": "string" },
                  "type": { "type": "string", "enum": ["CRUD", "DOMAIN"] },
                  "object": { "type": "string" },
                  "fields": { "type": "object" },
                  "guardrails": { "type": "object" }
                },
                "additionalProperties": false
              }
            },
            "dependencies": { "type": "array", "items": { "type": "string" } },
            "checkpoint_text": { "type": "string" }
          },
          "additionalProperties": false
        },
        "code_artifacts": {
          "type": "object",
          "required": ["apex", "soql", "tests"],
          "properties": {
            "apex": { "type": "array", "items": { "type": "object", "required": ["name", "content"] } },
            "soql": { "type": "array", "items": { "type": "string" } },
            "tests": { "type": "array", "items": { "type": "object", "required": ["name", "content"] } }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    }
  },
  "required": ["input", "output"],
  "additionalProperties": false
}
JSON

cat > force-app/main/default/staticresources/llm_contracts.resource-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">
  <cacheControl>Public</cacheControl>
  <contentType>application/json</contentType>
  <description>LLM I/O JSON schema contracts (input/output)</description>
</StaticResource>
XML

# -------------------------------
# Meeting fixtures (sample inputs)
# -------------------------------
cat > force-app/main/default/staticresources/meeting_fixtures/slice_example.json << 'JSON'
{
  "objects": [
    {
      "apiName": "Opportunity",
      "fields": ["Id", "Name", "StageName", "Amount", "CloseDate", "AccountId"],
      "piiFieldsRemoved": []
    },
    {
      "apiName": "Account",
      "fields": ["Id", "Name", "Industry", "AnnualRevenue"],
      "piiFieldsRemoved": []
    }
  ],
  "relationships": [
    { "parent": "Account", "child": "Opportunity", "type": "lookup", "field": "AccountId" }
  ],
  "tokenBudget": 420
}
JSON

cat > force-app/main/default/staticresources/meeting_fixtures.resource-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">
  <cacheControl>Public</cacheControl>
  <contentType>application/json</contentType>
  <description>Fixtures: sample schema slices & plan outputs</description>
</StaticResource>
XML

# -------------------------------
# Apex: Models
# -------------------------------
cat > force-app/main/default/classes/PlanModels.cls << 'APEX'
public with sharing class PlanModels {
    public class ActionDef {
        @AuraEnabled public String name;
        @AuraEnabled public String type; // CRUD or DOMAIN
        @AuraEnabled public String sobjectApiName;
        @AuraEnabled public Map<String, Object> fields;
        @AuraEnabled public Map<String, Object> guardrails;
    }
    public class Plan {
        @AuraEnabled public List<String> capabilities;
        @AuraEnabled public List<String> steps;
        @AuraEnabled public List<ActionDef> actions;
        @AuraEnabled public List<String> dependencies;
        @AuraEnabled public String checkpointText;
    }
    public class CodeArtifacts {
        @AuraEnabled public List<Map<String, String>> apex; // [{name, content}]
        @AuraEnabled public List<String> soql;
        @AuraEnabled public List<Map<String, String>> tests; // [{name, content}]
    }
    public class OrchestratorResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<String> logs;
        @AuraEnabled public List<String> warnings;
        @AuraEnabled public List<String> errors;
    }
}
APEX

cat > force-app/main/default/classes/PlanModels.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: PrivacyGuard
# -------------------------------
cat > force-app/main/default/classes/PrivacyGuard.cls << 'APEX'
public with sharing class PrivacyGuard {
    // Simple PII detector; extend per org policy.
    static Set<String> PII_FIELD_HINTS = new Set<String>{
        'ssn','social','tax','sin','dob','birth','passport','credit','card','cvv','iban','national'
    };

    public class RedactionReport {
        @AuraEnabled public Map<String, List<String>> removedByObject = new Map<String, List<String>>();
        @AuraEnabled public Integer totalRemoved = 0;
    }

    public static Map<String, Object> redactPIIFromSlice(Map<String, Object> slice, RedactionReport report) {
        if (report == null) report = new RedactionReport();
        List<Object> objects = (List<Object>) slice.get('objects');
        for (Object o : objects) {
            Map<String, Object> obj = (Map<String, Object>) o;
            String apiName = (String) obj.get('apiName');
            List<Object> fields = (List<Object>) obj.get('fields');
            List<String> keep = new List<String>();
            List<String> removed = new List<String>();
            for (Object f : fields) {
                String field = String.valueOf(f);
                String lower = field.toLowerCase();
                Boolean isPII = false;
                for (String hint : PII_FIELD_HINTS) {
                    if (lower.contains(hint)) { isPII = true; break; }
                }
                if (isPII) removed.add(field); else keep.add(field);
            }
            obj.put('fields', keep);
            obj.put('piiFieldsRemoved', removed);
            if (!report.removedByObject.containsKey(apiName)) report.removedByObject.put(apiName, new List<String>());
            report.removedByObject.get(apiName).addAll(removed);
            report.totalRemoved += removed.size();
        }
        return slice;
    }
}
APEX

cat > force-app/main/default/classes/PrivacyGuard.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: MetadataDiscovery
# -------------------------------
cat > force-app/main/default/classes/MetadataDiscovery.cls << 'APEX'
public with sharing class MetadataDiscovery {
    public class DiscoveryResult {
        @AuraEnabled public List<ObjectInfo> objects = new List<ObjectInfo>();
        @AuraEnabled public List<Map<String, String>> relationships = new List<Map<String, String>>();
    }
    public class ObjectInfo {
        @AuraEnabled public String apiName;
        @AuraEnabled public List<String> fields;
        @AuraEnabled public String label;
        @AuraEnabled public String keyPrefix;
    }

    @AuraEnabled(cacheable=true)
    public static DiscoveryResult enumerateOrgSchema(Set<String> objectApiNames) {
        DiscoveryResult dr = new DiscoveryResult();
        Set<String> targets = (objectApiNames == null || objectApiNames.isEmpty())
            ? new Set<String>(Schema.getGlobalDescribe().keySet())
            : objectApiNames;

        Map<String, Schema.SObjectType> global = Schema.getGlobalDescribe();
        for (String apiName : targets) {
            if (!global.containsKey(apiName)) continue;
            Schema.DescribeSObjectResult d = global.get(apiName).getDescribe();
            ObjectInfo oi = new ObjectInfo();
            oi.apiName = d.getName();
            oi.label = d.getLabel();
            oi.keyPrefix = d.getKeyPrefix();
            oi.fields = new List<String>();
            for (Schema.SObjectField f : d.fields.getMap().values()) {
                Schema.DescribeFieldResult fd = f.getDescribe();
                oi.fields.add(fd.getName());
                // Relationships
                if (fd.getRelationshipName() != null) {
                    dr.relationships.add(new Map<String, String>{
                        'parent' => d.getName(),
                        'child'  => fd.getReferenceTo().isEmpty() ? null : fd.getReferenceTo()[0].getDescribe().getName(),
                        'type'   => 'lookup',
                        'field'  => fd.getName()
                    });
                }
            }
            dr.objects.add(oi);
        }
        return dr;
    }
}
APEX

cat > force-app/main/default/classes/MetadataDiscovery.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: SchemaSlicer
# -------------------------------
cat > force-app/main/default/classes/SchemaSlicer.cls << 'APEX'
public with sharing class SchemaSlicer {
    public class SliceRequest {
        @AuraEnabled public String goal;
        @AuraEnabled public Set<String> candidateObjects;
        @AuraEnabled public Integer maxObjects = 15;
        @AuraEnabled public Integer maxFields = 120;
    }

    public static Map<String, Object> slice(MetadataDiscovery.DiscoveryResult discovered, SliceRequest req) {
        // Very simple heuristic: prioritize standard objects commonly used per goal keywords
        List<String> order = new List<String>();
        String g = (req.goal == null ? '' : req.goal.toLowerCase());
        if (g.contains('loan') || g.contains('eligibility')) {
            order.addAll(new List<String>{'Account','Contact','Opportunity'});
        } else if (g.contains('inventory') || g.contains('product')) {
            order.addAll(new List<String>{'Product2','Pricebook2','PricebookEntry','Asset','Order','OrderItem'});
        } else {
            order.addAll(new List<String>{'Lead','Account','Contact','Case','Opportunity'});
        }

        // Build the slice
        List<Object> objects = new List<Object>();
        Integer fieldCount = 0;
        for (String name : order) {
            for (MetadataDiscovery.ObjectInfo oi : discovered.objects) {
                if (oi.apiName == name && objects.size() < req.maxObjects) {
                    List<String> pick = new List<String>();
                    for (String f : oi.fields) {
                        if (fieldCount >= req.maxFields) break;
                        // Keep a compact useful subset by heuristic
                        if (new Set<String>{'Id','Name','Status','StageName','Amount','CloseDate','AccountId','OwnerId','Email','Phone',
                            'Industry','AnnualRevenue','Inventory__c','Balance__c','Score__c','Eligibility__c'}.contains(f)
                            || f.endsWith('Id') || f.endsWith('Date')) {
                            pick.add(f); fieldCount++;
                        }
                    }
                    Map<String, Object> entry = new Map<String, Object>{
                        'apiName' => oi.apiName,
                        'fields' => pick,
                        'piiFieldsRemoved' => new List<String>()
                    };
                    objects.add(entry);
                }
            }
        }
        Map<String, Object> slice = new Map<String, Object>{
            'objects' => objects,
            'relationships' => discovered.relationships,
            'tokenBudget' => estimateTokenBudget(objects)
        };

        // PII redaction
        PrivacyGuard.RedactionReport rpt = new PrivacyGuard.RedactionReport();
        return PrivacyGuard.redactPIIFromSlice(slice, rpt);
    }

    private static Integer estimateTokenBudget(List<Object> objects) {
        Integer approx = 0;
        for (Object obj : objects) {
            Map<String, Object> m = (Map<String, Object>) obj;
            approx += 8; // headers
            approx += ((List<Object>) m.get('fields')).size();
        }
        return approx * 4; // crude estimate
    }
}
APEX

cat > force-app/main/default/classes/SchemaSlicer.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: DomainActionRegistry & Invocable Factory
# -------------------------------
cat > force-app/main/default/classes/DomainActionRegistry.cls << 'APEX'
public with sharing class DomainActionRegistry {
    public class Template {
        @AuraEnabled public String name;
        @AuraEnabled public String type; // CRUD or DOMAIN
        @AuraEnabled public String sobjectApiName;
        @AuraEnabled public List<String> requiredFields;
    }

    public static Map<String, Template> registry() {
        Map<String, Template> r = new Map<String, Template>();
        Template t1 = new Template();
        t1.name = 'UpdateOpportunityStage';
        t1.type = 'DOMAIN';
        t1.sobjectApiName = 'Opportunity';
        t1.requiredFields = new List<String>{'Id','StageName'};
        r.put(t1.name, t1);

        Template t2 = new Template();
        t2.name = 'CRUD.Upsert';
        t2.type = 'CRUD';
        t2.sobjectApiName = 'Generic__c';
        t2.requiredFields = new List<String>{'Id'};
        r.put(t2.name, t2);
        return r;
    }
}
APEX

cat > force-app/main/default/classes/DomainActionRegistry.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

cat > force-app/main/default/classes/InvocableActionFactory.cls << 'APEX'
public with sharing class InvocableActionFactory {
    public interface IAction {
        PlanModels.OrchestratorResult execute(Map<String, Object> input);
    }

    // Example DOMAIN action
    public class UpdateOpportunityStage implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs = new List<String>();
            String oppId = (String) input.get('Id');
            String stage = (String) input.get('StageName');
            if (String.isBlank(oppId) || String.isBlank(stage)) {
                res.success = false;
                res.errors = new List<String>{'Missing Id or StageName'};
                return res;
            }
            Opportunity o = new Opportunity(Id=oppId, StageName=stage);
            try {
                update o;
                res.success = true;
                res.logs.add('Updated Opportunity ' + oppId + ' to stage ' + stage);
            } catch (DmlException e) {
                res.success = false;
                res.errors = new List<String>{ e.getMessage() };
            }
            return res;
        }
    }

    // Factory
    public static IAction get(String name) {
        if (name == 'UpdateOpportunityStage') return new UpdateOpportunityStage();
        // Extend: build from LLM code_artifacts in future iterations.
        throw new AuraHandledException('Unknown action: ' + name);
    }
}
APEX

cat > force-app/main/default/classes/InvocableActionFactory.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: Planner (Stage 2 - plan)
# -------------------------------
cat > force-app/main/default/classes/Planner.cls << 'APEX'
public with sharing class Planner {
    public static PlanModels.Plan producePlan(Map<String, Object> slice, String goal, Map<String, Object> constraints) {
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{'CRUD','DOMAIN'};
        p.steps = new List<String>{'Analyze goal','Choose actions','Assemble dependencies','Generate checkpoint'};
        p.dependencies = new List<String>{'FLS','Sharing'};
        p.checkpointText = 'I will update an Opportunity stage based on your instructions. Proceed?';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name = 'UpdateOpportunityStage';
        a.type = 'DOMAIN';
        a.sobjectApiName = 'Opportunity';
        a.fields = new Map<String, Object>{ 'Id' => null, 'StageName' => null };
        a.guardrails = new Map<String, Object>{ 'requireFLS' => true, 'requireSharing' => true };

        p.actions = new List<PlanModels.ActionDef>{ a };
        return p;
    }
}
APEX

cat > force-app/main/default/classes/Planner.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: CodeGenService (stub)
# -------------------------------
cat > force-app/main/default/classes/CodeGenService.cls << 'APEX'
public with sharing class CodeGenService {
    public static PlanModels.CodeArtifacts generate(PlanModels.Plan plan) {
        // Stub: In future, stitch LLM-generated files. For now, return empty arrays.
        PlanModels.CodeArtifacts ca = new PlanModels.CodeArtifacts();
        ca.apex = new List<Map<String, String>>();
        ca.soql = new List<String>();
        ca.tests = new List<Map<String, String>>();
        return ca;
    }
}
APEX

cat > force-app/main/default/classes/CodeGenService.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex: Action Orchestrator
# -------------------------------
cat > force-app/main/default/classes/ActionOrchestrator.cls << 'APEX'
public with sharing class ActionOrchestrator {
    @AuraEnabled
    public static PlanModels.OrchestratorResult run(PlanModels.Plan plan, Map<String, Object> userInputs, Boolean confirmed) {
        PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
        res.logs = new List<String>();
        if (!confirmed) {
            res.success = false;
            res.warnings = new List<String>{'Execution not confirmed'};
            return res;
        }
        // Enforce guardrails (simplified)
        for (PlanModels.ActionDef a : plan.actions) {
            // Business Rules Agent hook could go here
            InvocableActionFactory.IAction impl = InvocableActionFactory.get(a.name);
            PlanModels.OrchestratorResult step = impl.execute((Map<String, Object>) userInputs.get(a.name));
            if (!step.success) {
                res.success = false;
                res.errors = step.errors;
                return res;
            }
            res.logs.addAll(step.logs);
        }
        res.success = true;
        return res;
    }
}
APEX

cat > force-app/main/default/classes/ActionOrchestrator.cls-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <status>Active</status>
</ApexClass>
XML

# -------------------------------
# Apex Tests (70%+ target when filled)
# -------------------------------
cat > force-app/main/default/classes/tests/PrivacyGuardTests.cls << 'APEX'
@IsTest
private class PrivacyGuardTests {
    @IsTest static void testRedaction() {
        Map<String,Object> slice = (Map<String,Object>) JSON.deserializeUntyped('{"objects":[{"apiName":"Contact","fields":["Id","Name","SSN__c","Email"],"piiFieldsRemoved":[]}]}');
        PrivacyGuard.RedactionReport rpt = new PrivacyGuard.RedactionReport();
        Map<String,Object> out = PrivacyGuard.redactPIIFromSlice(slice, rpt);
        System.assertEquals(1, rpt.totalRemoved);
        List<Object> objs = (List<Object>) out.get('objects');
        Map<String,Object> c = (Map<String,Object>) objs[0];
        List<Object> fields = (List<Object>) c.get('fields');
        System.assert(!fields.contains('SSN__c'),'PII field should be removed');
    }
}
APEX

cat > force-app/main/default/classes/tests/MetadataDiscoveryTests.cls << 'APEX'
@IsTest
private class MetadataDiscoveryTests {
    @IsTest static void testEnumerate() {
        MetadataDiscovery.DiscoveryResult dr = MetadataDiscovery.enumerateOrgSchema(new Set<String>{'Account'});
        System.assertNotEquals(0, dr.objects.size());
        System.assertEquals('Account', dr.objects[0].apiName);
    }
}
APEX

cat > force-app/main/default/classes/tests/SchemaSlicerTests.cls << 'APEX'
@IsTest
private class SchemaSlicerTests {
    @IsTest static void testSlice() {
        MetadataDiscovery.DiscoveryResult dr = new MetadataDiscovery.DiscoveryResult();
        MetadataDiscovery.ObjectInfo oi = new MetadataDiscovery.ObjectInfo();
        oi.apiName='Opportunity'; oi.label='Opportunity'; oi.keyPrefix='006';
        oi.fields=new List<String>{'Id','Name','StageName','Amount','CloseDate','SSN__c'};
        dr.objects.add(oi);
        SchemaSlicer.SliceRequest req = new SchemaSlicer.SliceRequest();
        req.goal='Loan eligibility';
        Map<String,Object> slice = SchemaSlicer.slice(dr, req);
        List<Object> objs = (List<Object>) slice.get('objects');
        Map<String,Object> opp = (Map<String,Object>) objs[0];
        List<Object> fields = (List<Object>) opp.get('fields');
        System.assert(!fields.contains('SSN__c'));
    }
}
APEX

cat > force-app/main/default/classes/tests/PlannerAndOrchestratorTests.cls << 'APEX'
@IsTest
private class PlannerAndOrchestratorTests {
    @IsTest static void testPlanAndOrchestrate_NoConfirm() {
        Map<String,Object> slice = new Map<String,Object>{ 'objects' => new List<Object>() };
        PlanModels.Plan p = Planner.producePlan(slice, 'Update Opp Stage', new Map<String,Object>());
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, new Map<String,Object>(), false);
        System.assertEquals(false, r.success);
    }
}
APEX

# -------------------------------
# Permission set for generated features
# -------------------------------
cat > force-app/main/default/permissionsets/GenAIAgentPermission.permissionset-meta.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
  <hasActivationRequired>false</hasActivationRequired>
  <label>GenAIAgentPermission</label>
</PermissionSet>
XML

# -------------------------------
# Prompt templates (stubs)
# -------------------------------
cat > force-app/main/default/promptTemplates/LoanEligibility.prompt << 'TXT'
You are an Agentforce planner. Use the provided schema_slice.json, goal, and constraints to produce JSON:
- plan
- code_artifacts
Conform exactly to the output schema in the static resource llm_contracts/io_contracts.json.
Goal: Loan Eligibility
Constraints: Do not include PII or objects outside the slice. Return plan.checkpoint_text for user confirmation.
TXT

cat > force-app/main/default/promptTemplates/InventoryCheck.prompt << 'TXT'
You are an Agentforce planner. Use the schema slice to plan and generate code artifacts for inventory check.
Follow the same I/O contract and guardrails as LoanEligibility.prompt.
TXT

# -------------------------------
# GitHub Actions: CI
# -------------------------------
cat > .github/workflows/apex-tests.yml << 'YML'
name: Apex Tests
on:
  pull_request:
  push:
    branches: [ main, master ]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: sfdx-actions/setup-sfdx@v1
      - name: Auth Dev Hub
        run: echo "${{ secrets.SFDX_URL }}" > sfdx_auth.txt && sfdx auth:sfdxurl:store -f sfdx_auth.txt -a devhub
      - name: Create Scratch Org
        run: sfdx force:org:create -s -f config/project-scratch-def.json -a ci-org -d 1
      - name: Push Source
        run: sfdx force:source:push -u ci-org
      - name: Assign Permset
        run: sfdx force:user:permset:assign -n GenAIAgentPermission -u ci-org || true
      - name: Run Tests
        run: sfdx force:apex:test:run -u ci-org -r human -c -w 30
      - name: Delete Scratch Org
        if: always()
        run: sfdx force:org:delete -u ci-org -p
YML

# -------------------------------
# Dev script
# -------------------------------
cat > scripts/dev-setup.sh << 'BASH'
#!/usr/bin/env bash
set -euo pipefail
aliasorg="${1:-agent-data-aware}"
sf org create scratch --definition-file config/project-scratch-def.json --alias "$aliasorg" --set-default --duration-days 7 --wait 10
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission -o "$aliasorg" || true
echo "Done. Open org: sf org open -o $aliasorg"
BASH
chmod +x scripts/dev-setup.sh

# -------------------------------
# Docs links
# -------------------------------
cat > docs/README-LLM-IO.md << 'MD'
# LLM I/O Contract
- Input: `schema_slice.json`, `goal`, `constraints`
- Output: `plan.json`, `code_artifacts` (Apex/Tests/SOQL)
See `staticresources/llm_contracts/io_contracts.json`.
MD

echo "✅ Scaffolding created."
