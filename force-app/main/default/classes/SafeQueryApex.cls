public class SafeQueryApex {
    public static String ExecuteSOQL(String objectName, String fieldsJson, String whereClause, Integer limitRecords) {
        List<String> fields = (List<String>) JSON.deserialize(fieldsJson, List<String>.class);
        // Enforce FLS
        fields = FLS.enforce(objectName, fields);
        String query = SOQLBuilder.build(objectName, fields, whereClause, limitRecords);
        List<SObject> records = Database.query(query);
        return JSON.serialize(records);
    }
}