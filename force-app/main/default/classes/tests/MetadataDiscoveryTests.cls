@IsTest
private class MetadataDiscoveryTests {
    @IsTest static void testEnumerate() {
        MetadataDiscovery.DiscoveryResult dr = MetadataDiscovery.enumerateOrgSchema(new Set<String>{'Account'});
        System.assertNotEquals(0, dr.objects.size());
        System.assertEquals('Account', dr.objects[0].apiName);
    }
}
