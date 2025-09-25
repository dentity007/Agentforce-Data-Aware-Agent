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
