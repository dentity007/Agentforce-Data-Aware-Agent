@IsTest
private class AgentSchemaTests {
    @IsTest static void testBuildSchemaGraph_andLoad(){
        Test.startTest();
        OrgSchemaBootstrap.SchemaGraphDTO g = OrgSchemaBootstrap.buildSchemaGraph();
        Test.stopTest();
        System.assertNotEquals(null, g);
        System.assertNotEquals(null, SchemaGraphStore.load());
    }
    @IsTest static void testMetadataNavigator_FindObjects_AndFields(){
        String objectsJson = MetadataNavigatorApex.FindObjects('lead');
        List<String> objs = (List<String>) JSON.deserialize(objectsJson, List<String>.class);
        System.assert(!objs.isEmpty());
        String fieldsJson = MetadataNavigatorApex.FindFields('Lead', 'email');
        List<String> flds = (List<String>) JSON.deserialize(fieldsJson, List<String>.class);
        System.assert(!flds.isEmpty());
    }
    @IsTest static void testOrgSchemaPaths_shortestPath(){
        String pathJson = MetadataNavigatorApex.FindRelationshipPath('Opportunity','Account');
        System.assertNotEquals(null, pathJson);
    }
}