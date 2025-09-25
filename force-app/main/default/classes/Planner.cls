public with sharing class Planner {
    public static PlanModels.Plan producePlan(Map<String, Object> slice, String goal, Map<String, Object> constraints) {
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{'CRUD','DOMAIN'};
        p.steps = new List<String>{'Analyze goal','Choose actions','Assemble dependencies','Generate checkpoint'};
        p.dependencies = new List<String>{'FLS','Sharing'};
        p.checkpointText = 'I will update an Opportunity stage based on your instructions. Proceed?';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name = 'UpdateOpportunityStage';
        a.type = 'DOMAIN';
        a.sobjectApiName = 'Opportunity';
        a.fields = new Map<String, Object>{ 'Id' => null, 'StageName' => null };
        a.guardrails = new Map<String, Object>{ 'requireFLS' => true, 'requireSharing' => true };

        p.actions = new List<PlanModels.ActionDef>{ a };
        return p;
    }
}
