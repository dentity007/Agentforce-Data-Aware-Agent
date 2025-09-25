@IsTest
private class PlannerRouteTests {
    @IsTest
    static void testRoutesToInventoryReserve() {
        Map<String, Object> slice = new Map<String, Object>{ 'objects' => new List<Object>() };
        PlanModels.Plan p = Planner.producePlan(slice, 'Please reserve inventory for product X', new Map<String, Object>());

        System.assertEquals(1, p.actions.size(), 'One action expected');
        System.assertEquals('InventoryReserve', p.actions[0].name);
        System.assertEquals('Task', p.actions[0].sobjectApiName);
        System.assert(p.checkpointText.contains('reserve inventory'), 'Checkpoint text should mention reserve inventory');
    }

    @IsTest
    static void testDefaultRoutesToUpdateOpportunityStage() {
        Map<String, Object> slice = new Map<String, Object>{ 'objects' => new List<Object>() };
        PlanModels.Plan p = Planner.producePlan(slice, 'Update the opportunity stage', new Map<String, Object>());

        System.assertEquals(1, p.actions.size(), 'One action expected');
        System.assertEquals('UpdateOpportunityStage', p.actions[0].name);
        System.assertEquals('Opportunity', p.actions[0].sobjectApiName);
    }
}