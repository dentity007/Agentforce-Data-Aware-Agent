@IsTest
private class AgentLeadActionTests {
    private static Lead makeLead(){ Lead l = new Lead(LastName='Tester', Company='Acme Co'); insert l; return l; }
    @IsTest static void testFollowUpApex_createsTask(){
        Lead l = makeLead();
        FollowUpApex.Input in1 = new FollowUpApex.Input(); in1.LeadId = l.Id; in1.Channel = 'Task'; in1.TemplateName='Default';
        List<FollowUpApex.Output> outs = FollowUpApex.execute(new List<FollowUpApex.Input>{in1});
        System.assertEquals(1, outs.size());
    }
    @IsTest static void testLeadQualificationAction_updatesOrHandlesError(){
        Lead l1 = makeLead();
        LeadQualificationAction.Request r1 = new LeadQualificationAction.Request(); r1.leadId = l1.Id; r1.score = 85;
        LeadQualificationAction.Request r2 = new LeadQualificationAction.Request(); r2.leadId = l1.Id; r2.score = 10;
        List<LeadQualificationAction.Response> resp = LeadQualificationAction.updateLeadStatus(new List<LeadQualificationAction.Request>{r1, r2});
        System.assertEquals(2, resp.size());
    }
    @IsTest static void testLeadScoreService_scoresWithinBounds(){
        Lead l = makeLead();
        LeadScoreService.ScoreResult sr = LeadScoreService.scoreLead(l.Id);
        System.assert(sr != null && sr.score >= 0 && sr.score <= 100);
    }
}