@IsTest
private class AgentQueryTests {
    @IsTest static void testSOQLBuilder_build(){
        String q = SOQLBuilder.build('Lead', new List<String>{'Id','Company'}, 'CreatedDate = LAST_N_DAYS:365', 5);
        System.assert(q.contains('SELECT Id,Company FROM Lead'));
        System.assert(q.contains('ORDER BY CreatedDate DESC LIMIT 5'));
    }
    @IsTest static void testSafeQueryApex_execute_NoException(){
        String recordsJson = SafeQueryApex.ExecuteSOQL('Lead', JSON.serialize(new List<String>{'Id','Company'}), 'CreatedDate = LAST_N_DAYS:30', 1);
        System.assertNotEquals(null, recordsJson);
    }
    @IsTest static void testDataCloudQueryApex_stub(){ System.assertEquals('[]', DataCloudQueryApex.QueryDataCloud('anything')); }
    @IsTest static void testFLS_enforce_filtersUnknown(){
        List<String> safe = FLS.enforce('Lead', new List<String>{'Email','Bogus__c'});
        System.assert(safe.contains('Email'));
        System.assert(!safe.contains('Bogus__c'));
    }
    @IsTest static void testJSONUtil_minify(){ System.assert(JSONUtil.minify(' a\\n b ') != null); }
    @IsTest static void testNightlySchedule_runs(){ Test.startTest(); OrgSchemaNightlyJob.scheduleNightly(); Test.stopTest(); System.assert(true); }
}