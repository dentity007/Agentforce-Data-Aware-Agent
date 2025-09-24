public class MetadataDiscoverApex {
    public class DiscoveryResult {
        @AuraEnabled public Map<String, List<String>> objects;
        @AuraEnabled public Map<String, Map<String, String>> fields;
        @AuraEnabled public String inventoryField;
    }

    public static String discoverSchema(String objectName) {
        DiscoveryResult result = new DiscoveryResult();
        result.objects = new Map<String, List<String>>();
        result.fields = new Map<String, Map<String, String>>();

        try {
            // Get object metadata
            Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objectName).getDescribe();

            // Get all fields for this object
            Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();
            Map<String, String> fieldDetails = new Map<String, String>();

            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
                if (fieldDesc.isAccessible()) {
                    String fieldType = String.valueOf(fieldDesc.getType());
                    fieldDetails.put(fieldName, fieldType);

                    // Look for inventory-related fields
                    if (fieldName.toLowerCase().contains('inventory') ||
                        fieldName.toLowerCase().contains('stock') ||
                        fieldName.toLowerCase().contains('quantity')) {
                        result.inventoryField = fieldName;
                    }
                }
            }

            result.fields.put(objectName, fieldDetails);
            result.objects.put(objectName, new List<String>(fieldMap.keySet()));

        } catch (Exception e) {
            result.inventoryField = 'Quantity__c'; // fallback
        }

        return JSON.serialize(result);
    }

    public static String findInventoryField(String objectName) {
        try {
            Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();

            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
                if (fieldDesc.isAccessible() &&
                    (fieldName.toLowerCase().contains('inventory') ||
                     fieldName.toLowerCase().contains('stock') ||
                     fieldName.toLowerCase().contains('quantity'))) {
                    return fieldName;
                }
            }
        } catch (Exception e) {
            // fallback to common field names
        }
        return 'Quantity__c'; // default fallback
    }
}