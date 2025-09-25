@IsTest
private class InventoryReserveTests {
    @IsTest
    static void testInventoryReserveCreatesTask() {
        // Build a minimal plan that includes the InventoryReserve action
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{'DOMAIN'};
        p.steps = new List<String>{'Choose actions'};
        p.dependencies = new List<String>{'FLS','Sharing'};
        p.checkpointText = 'Reserve inventory confirmation';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name = 'InventoryReserve';
        a.type = 'DOMAIN';
        a.sobjectApiName = 'Task';
        a.fields = new Map<String, Object>{
            'Product2Id' => null,
            'Quantity'   => null,
            'AccountId'  => null
        };
        a.guardrails = new Map<String, Object>{ 'requireFLS' => true, 'requireSharing' => true };
        p.actions = new List<PlanModels.ActionDef>{ a };

        // Prepare user inputs (use a fake Product2 Id format is okay; we store it in Task.Description)
        Map<String, Object> inputs = new Map<String, Object>{
            'InventoryReserve' => new Map<String, Object>{
                'Product2Id' => '01t000000000001', // placeholder Id format for Product2
                'Quantity'   => 3,
                // 'AccountId' can be omitted in test; Task relates without WhatId
            }
        };

        // Count Tasks before
        Integer beforeCount = [SELECT count() FROM Task];

        // Run orchestrator with confirmation
        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, inputs, true);
        System.assertEquals(true, r.success, 'Orchestrator should succeed');

        // Verify a Task was created
        Integer afterCount = [SELECT count() FROM Task];
        System.assertEquals(beforeCount + 1, afterCount, 'One Task should be inserted');

        // Optional: fetch the Task and verify content
        Task inserted = [SELECT Id, Subject, Priority, Status, Description FROM Task ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('Inventory Reserve', inserted.Subject);
        System.assertEquals('High', inserted.Priority);
        System.assertEquals('Not Started', inserted.Status);
        System.assert(inserted.Description.contains('Product2Id: 01t000000000001'), 'Description should include Product2Id');
        System.assert(inserted.Description.contains('Quantity: 3'), 'Description should include Quantity');
    }

    @IsTest
    static void testInventoryReserveValidatesInputs() {
        // Missing Quantity → should fail
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities = new List<String>{'DOMAIN'};
        p.steps = new List<String>{'Choose actions'};
        p.dependencies = new List<String>{'FLS','Sharing'};
        p.checkpointText = 'Reserve inventory confirmation';

        PlanModels.ActionDef a = new PlanModels.ActionDef();
        a.name = 'InventoryReserve';
        a.type = 'DOMAIN';
        a.sobjectApiName = 'Task';
        a.fields = new Map<String, Object>{ 'Product2Id' => null, 'Quantity' => null };
        a.guardrails = new Map<String, Object>{ 'requireFLS' => true, 'requireSharing' => true };
        p.actions = new List<PlanModels.ActionDef>{ a };

        Map<String, Object> badInputs = new Map<String, Object>{
            'InventoryReserve' => new Map<String, Object>{
                'Product2Id' => '01t000000000001'
                // Quantity missing
            }
        };

        PlanModels.OrchestratorResult r = ActionOrchestrator.run(p, badInputs, true);
        System.assertEquals(false, r.success, 'Should fail without Quantity');
    }
}