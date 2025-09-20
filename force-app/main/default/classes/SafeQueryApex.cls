public class SafeQueryApex {
    public static String ExecuteSOQL(String objectApiName, String fields, String filters, Integer limitSize) {
        // Enforce FLS
        List<String> fieldList = (List<String>) JSON.deserialize(fields, List<String>.class);
        fieldList = FLS.enforce(objectApiName, fieldList);
        String query = SOQLBuilder.build(objectApiName, fieldList, filters, limitSize);
        List<SObject> records = Database.query(query);
        return JSON.serialize(records);
    }
}