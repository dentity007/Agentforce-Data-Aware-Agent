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
