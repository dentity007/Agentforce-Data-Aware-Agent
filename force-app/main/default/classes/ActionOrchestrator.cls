public with sharing class ActionOrchestrator {
    @AuraEnabled
    public static PlanModels.OrchestratorResult run(PlanModels.Plan plan, Map<String, Object> userInputs, Boolean confirmed) {
        PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
        res.logs = new List<String>();
        if (!confirmed) {
            res.success = false;
            res.warnings = new List<String>{'Execution not confirmed'};
            return res;
        }
        // Enforce guardrails (simplified)
        for (PlanModels.ActionDef a : plan.actions) {
            // Business Rules Agent hook could go here
            InvocableActionFactory.IAction impl = InvocableActionFactory.get(a.name);
            PlanModels.OrchestratorResult step = impl.execute((Map<String, Object>) userInputs.get(a.name));
            if (!step.success) {
                res.success = false;
                res.errors = step.errors;
                return res;
            }
            res.logs.addAll(step.logs);
        }
        res.success = true;
        return res;
    }
}
