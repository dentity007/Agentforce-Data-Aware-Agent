@IsTest
private class SchemaSlicerTests {
    @IsTest static void testSlice() {
        MetadataDiscovery.DiscoveryResult dr = new MetadataDiscovery.DiscoveryResult();
        MetadataDiscovery.ObjectInfo oi = new MetadataDiscovery.ObjectInfo();
        oi.apiName='Opportunity'; oi.label='Opportunity'; oi.keyPrefix='006';
        oi.fields=new List<String>{'Id','Name','StageName','Amount','CloseDate','SSN__c'};
        dr.objects.add(oi);
        SchemaSlicer.SliceRequest req = new SchemaSlicer.SliceRequest();
        req.goal='Loan eligibility';
        Map<String,Object> slice = SchemaSlicer.slice(dr, req);
        List<Object> objs = (List<Object>) slice.get('objects');
        Map<String,Object> opp = (Map<String,Object>) objs[0];
        List<Object> fields = (List<Object>) opp.get('fields');
        System.assert(!fields.contains('SSN__c'));
    }
}
