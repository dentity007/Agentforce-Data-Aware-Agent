public class FLS {
    public static List<String> enforce(String objectName, List<String> fields) {
        List<String> safeFields = new List<String>();
        Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();
        for (String field : fields) {
            if (fieldMap.containsKey(field) && fieldMap.get(field).getDescribe().isAccessible()) {
                safeFields.add(field);
            }
        }
        return safeFields;
    }
}