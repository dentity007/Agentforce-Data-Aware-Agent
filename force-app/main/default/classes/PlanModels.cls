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
