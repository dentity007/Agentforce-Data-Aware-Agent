public class MetadataNavigatorApex {
    public static String FindObjects(String searchTerm) {
        List<String> matchingObjects = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String objName : gd.keySet()) {
            if (objName.containsIgnoreCase(searchTerm)) {
                matchingObjects.add(objName);
            }
        }
        return JSON.serialize(matchingObjects);
    }

    public static String FindFields(String objectName, String searchTerm) {
        List<String> matchingFields = new List<String>();
        Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objectName).getDescribe();
        for (String fieldName : objDesc.fields.getMap().keySet()) {
            if (fieldName.containsIgnoreCase(searchTerm)) {
                matchingFields.add(fieldName);
            }
        }
        return JSON.serialize(matchingFields);
    }

    public static String FindRelationshipPath(String fromObject, String toObject) {
        // Stub: simple path
        Map<String, String> path = new Map<String, String>();
        path.put('path', fromObject + ' -> ' + toObject);
        return JSON.serialize(path);
    }
}