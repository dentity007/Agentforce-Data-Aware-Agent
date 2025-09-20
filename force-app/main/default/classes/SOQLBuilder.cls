public class SOQLBuilder {
    public static String build(String objectName, List<String> fields, String whereClause, Integer limitRecords) {
        String query = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName;
        if (String.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }
        query += ' ORDER BY CreatedDate DESC';
        if (limitRecords != null && limitRecords > 0) {
            query += ' LIMIT ' + limitRecords;
        }
        return query;
    }
}