@IsTest
private class PlannerAndOrchestratorTests {
    @IsTest static void testPlanAndOrchestrate_NoConfirm() {
        Map<String,Object> slice = new Map<String,Object>{ 'objects' => new List<Object>() };
        PlanModels.Plan p = Planner.producePlan(slice, 'Update Opp Stage', new Map<String,Object>());
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, new Map<String,Object>(), false);
        System.assertEquals(false, r.success);
    }
}
