public with sharing class InvocableActionFactory {
    public interface IAction {
        PlanModels.OrchestratorResult execute(Map<String, Object> input);
    }

    // Example DOMAIN action
    public class UpdateOpportunityStage implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs = new List<String>();
            String oppId = (String) input.get('Id');
            String stage = (String) input.get('StageName');
            if (String.isBlank(oppId) || String.isBlank(stage)) {
                res.success = false;
                res.errors = new List<String>{'Missing Id or StageName'};
                return res;
            }
            Opportunity o = new Opportunity(Id=oppId, StageName=stage);
            try {
                update o;
                res.success = true;
                res.logs.add('Updated Opportunity ' + oppId + ' to stage ' + stage);
            } catch (DmlException e) {
                res.success = false;
                res.errors = new List<String>{ e.getMessage() };
            }
            return res;
        }
    }

    // Factory
    public static IAction get(String name) {
        if (name == 'UpdateOpportunityStage') return new UpdateOpportunityStage();
        // Extend: build from LLM code_artifacts in future iterations.
        throw new AuraHandledException('Unknown action: ' + name);
    }
}
