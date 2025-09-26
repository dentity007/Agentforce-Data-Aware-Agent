@IsTest
private class OrchestratorCheckpointGuardTests {

    /** Missing Quantity gets blocked before DML (InventoryReserve). */
    @IsTest
    static void testMissingQuantityIsBlocked() {
        // Plan chooses InventoryReserve with guardrails (optional: AccountId; numeric: Quantity)
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{ 'DOMAIN' };
        p.steps        = new List<String>{ 'Choose actions' };
        p.dependencies = new List<String>{ 'FLS', 'Sharing' };
        p.checkpointText = 'Reserve inventory';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name           = 'InventoryReserve';
        a.type           = 'DOMAIN';
        a.sobjectApiName = 'Task';
        a.fields = new Map<String, Object>{
            'Product2Id' => null,
            'Quantity'   => null,
            'AccountId'  => null
        };
        a.guardrails = new Map<String, Object>{
            'optionalFields' => (Object) new List<String>{ 'AccountId' },
            'numericFields'  => (Object) new List<String>{ 'Quantity' }
        };
        p.actions = new List<PlanModels.ActionDef>{ a };

        // Provide Product2Id but omit Quantity
        Map<String, Object> inputs = new Map<String, Object>{
            'InventoryReserve' => new Map<String, Object>{
                'Product2Id' => '01t000000000001'
            }
        };

        Integer beforeTasks = [SELECT count() FROM Task];
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, inputs, true);
        Integer afterTasks = [SELECT count() FROM Task];

        System.assertEquals(false, r.success, 'Should fail preflight');
        System.assertEquals(beforeTasks, afterTasks, 'No Task should be inserted due to guard block');
        System.assertEquals(true, (r.errors != null && r.errors.size() > 0), 'Expect error messages');
    }

    /** Invalid (non-numeric) Quantity is blocked. */
    @IsTest
    static void testNonNumericQuantityIsBlocked() {
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{ 'DOMAIN' };
        p.steps        = new List<String>{ 'Choose actions' };
        p.dependencies = new List<String>{ 'FLS', 'Sharing' };
        p.checkpointText = 'Reserve inventory';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name           = 'InventoryReserve';
        a.type           = 'DOMAIN';
        a.sobjectApiName = 'Task';
        a.fields = new Map<String, Object>{ 'Product2Id' => null, 'Quantity' => null };
        a.guardrails = new Map<String, Object>{ 'numericFields' => (Object) new List<String>{ 'Quantity' } };
        p.actions = new List<PlanModels.ActionDef>{ a };

        Map<String, Object> inputs = new Map<String, Object>{
            'InventoryReserve' => new Map<String, Object>{
                'Product2Id' => '01t000000000001',
                'Quantity'   => 'three' // invalid
            }
        };

        Integer beforeTasks = [SELECT count() FROM Task];
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, inputs, true);
        Integer afterTasks = [SELECT count() FROM Task];

        System.assertEquals(false, r.success);
        System.assertEquals(beforeTasks, afterTasks);
        System.assertEquals(true, (r.errors != null && r.errors.size() > 0));
    }

    /** Happy path passes guard and inserts a Task. */
    @IsTest
    static void testValidInputsPassGuard() {
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{ 'DOMAIN' };
        p.steps        = new List<String>{ 'Choose actions' };
        p.dependencies = new List<String>{ 'FLS', 'Sharing' };
        p.checkpointText = 'Reserve inventory';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name           = 'InventoryReserve';
        a.type           = 'DOMAIN';
        a.sobjectApiName = 'Task';
        a.fields = new Map<String, Object>{ 'Product2Id' => null, 'Quantity' => null };
        a.guardrails = new Map<String, Object>{ 'numericFields' => (Object) new List<String>{ 'Quantity' } };
        p.actions = new List<PlanModels.ActionDef>{ a };

        Map<String, Object> inputs = new Map<String, Object>{
            'InventoryReserve' => new Map<String, Object>{
                'Product2Id' => '01t000000000001',
                'Quantity'   => 2
            }
        };

        Integer beforeTasks = [SELECT count() FROM Task];
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, inputs, true);
        Integer afterTasks = [SELECT count() FROM Task];

        System.assertEquals(true, r.success);
        System.assertEquals(beforeTasks + 1, afterTasks, 'Task should be inserted');
    }
}
