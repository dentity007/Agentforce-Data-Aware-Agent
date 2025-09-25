@IsTest
private class PrivacyGuardTests {
    @IsTest static void testRedaction() {
        Map<String,Object> slice = (Map<String,Object>) JSON.deserializeUntyped('{"objects":[{"apiName":"Contact","fields":["Id","Name","SSN__c","Email"],"piiFieldsRemoved":[]}]}');
        PrivacyGuard.RedactionReport rpt = new PrivacyGuard.RedactionReport();
        Map<String,Object> out = PrivacyGuard.redactPIIFromSlice(slice, rpt);
        System.assertEquals(1, rpt.totalRemoved);
        List<Object> objs = (List<Object>) out.get('objects');
        Map<String,Object> c = (Map<String,Object>) objs[0];
        List<Object> fields = (List<Object>) c.get('fields');
        System.assert(!fields.contains('SSN__c'),'PII field should be removed');
    }
}
