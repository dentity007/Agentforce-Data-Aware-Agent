public class MetadataNavigatorApex {
    public static String FindObjects(String concept) {
        List<String> matchingObjects = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String objName : gd.keySet()) {
            if (objName.containsIgnoreCase(concept)) {
                matchingObjects.add(objName);
            }
        }
        return JSON.serialize(matchingObjects);
    }

    public static String FindFields(String objectApiName, String concept) {
        List<String> matchingFields = new List<String>();
        Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        for (String fieldName : objDesc.fields.getMap().keySet()) {
            if (fieldName.containsIgnoreCase(concept)) {
                matchingFields.add(fieldName);
            }
        }
        return JSON.serialize(matchingFields);
    }

    public static String FindRelationshipPath(String sourceObject, String targetObject) {
        // Stub: simple path
        Map<String, String> path = new Map<String, String>();
        path.put('path', sourceObject + ' -> ' + targetObject);
        return JSON.serialize(path);
    }
}