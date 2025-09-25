public with sharing class PrivacyGuard {
    // Simple PII detector; extend per org policy.
    static Set<String> PII_FIELD_HINTS = new Set<String>{
        'ssn','social','tax','sin','dob','birth','passport','credit','card','cvv','iban','national'
    };

    public class RedactionReport {
        @AuraEnabled public Map<String, List<String>> removedByObject = new Map<String, List<String>>();
        @AuraEnabled public Integer totalRemoved = 0;
    }

    public static Map<String, Object> redactPIIFromSlice(Map<String, Object> slice, RedactionReport report) {
        if (report == null) report = new RedactionReport();
        List<Object> objects = (List<Object>) slice.get('objects');
        for (Object o : objects) {
            Map<String, Object> obj = (Map<String, Object>) o;
            String apiName = (String) obj.get('apiName');
            List<Object> fields = (List<Object>) obj.get('fields');
            List<String> keep = new List<String>();
            List<String> removed = new List<String>();
            for (Object f : fields) {
                String field = String.valueOf(f);
                String lower = field.toLowerCase();
                Boolean isPII = false;
                for (String hint : PII_FIELD_HINTS) {
                    if (lower.contains(hint)) { isPII = true; break; }
                }
                if (isPII) removed.add(field); else keep.add(field);
            }
            obj.put('fields', keep);
            obj.put('piiFieldsRemoved', removed);
            if (!report.removedByObject.containsKey(apiName)) report.removedByObject.put(apiName, new List<String>());
            report.removedByObject.get(apiName).addAll(removed);
            report.totalRemoved += removed.size();
        }
        return slice;
    }
}
