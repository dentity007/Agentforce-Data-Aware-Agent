@IsTest
private class InventoryReserveTests {
    @IsTest
    static void testInventoryReserveCreatesTask() {
        // Test the InventoryReserve action directly
        InvocableActionFactory.InventoryReserve action = new InvocableActionFactory.InventoryReserve();

        // Prepare input data
        Map<String, Object> input = new Map<String, Object>{
            'Product2Id' => '01t000000000001',
            'Quantity' => 3,
            'AccountId' => '001000000000001'
        };

        // Count Tasks before
        Integer beforeCount = [SELECT count() FROM Task];

        // Execute the action
        Test.startTest();
        PlanModels.OrchestratorResult result = action.execute(input);
        Test.stopTest();

        // Verify success
        System.assertEquals(true, result.success, 'Action should succeed');

        // Verify a Task was created
        Integer afterCount = [SELECT count() FROM Task];
        System.assertEquals(beforeCount + 1, afterCount, 'One Task should be inserted');

        // Verify Task content
        Task inserted = [SELECT Id, Subject, Priority, Status, Description, WhatId FROM Task ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('Inventory Reserve', inserted.Subject);
        System.assertEquals('High', inserted.Priority);
        System.assertEquals('Not Started', inserted.Status);
        System.assert(inserted.Description.contains('Product2Id: 01t000000000001'), 'Description should include Product2Id');
        System.assert(inserted.Description.contains('Quantity: 3'), 'Description should include Quantity');
        System.assert(inserted.Description.contains('AccountId: 001000000000001'), 'Description should include AccountId');
        System.assertEquals('001000000000001', inserted.WhatId, 'Task should be related to the Account');
    }

    @IsTest
    static void testInventoryReserveValidatesInputs() {
        InvocableActionFactory.InventoryReserve action = new InvocableActionFactory.InventoryReserve();

        // Test missing Quantity
        Map<String, Object> badInput1 = new Map<String, Object>{
            'Product2Id' => '01t000000000001'
            // Quantity missing
        };

        PlanModels.OrchestratorResult result1 = action.execute(badInput1);
        System.assertEquals(false, result1.success, 'Should fail without Quantity');
        System.assert(result1.errors[0].contains('Missing required field: Quantity'), 'Should mention missing Quantity');

        // Test missing Product2Id
        Map<String, Object> badInput2 = new Map<String, Object>{
            'Quantity' => 5
            // Product2Id missing
        };

        PlanModels.OrchestratorResult result2 = action.execute(badInput2);
        System.assertEquals(false, result2.success, 'Should fail without Product2Id');
        System.assert(result2.errors[0].contains('Missing required field: Product2Id'), 'Should mention missing Product2Id');

        // Test invalid Quantity
        Map<String, Object> badInput3 = new Map<String, Object>{
            'Product2Id' => '01t000000000001',
            'Quantity' => 'invalid'
        };

        PlanModels.OrchestratorResult result3 = action.execute(badInput3);
        System.assertEquals(false, result3.success, 'Should fail with invalid Quantity');
        System.assert(result3.errors[0].contains('Invalid Quantity'), 'Should mention invalid Quantity');
    }

    @IsTest
    static void testInventoryReserveWithoutAccountId() {
        InvocableActionFactory.InventoryReserve action = new InvocableActionFactory.InventoryReserve();

        // Test without AccountId (should still work)
        Map<String, Object> input = new Map<String, Object>{
            'Product2Id' => '01t000000000001',
            'Quantity' => 2
            // No AccountId
        };

        Test.startTest();
        PlanModels.OrchestratorResult result = action.execute(input);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Action should succeed without AccountId');

        // Verify Task was created without WhatId
        Task inserted = [SELECT Id, WhatId, Description FROM Task ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(null, inserted.WhatId, 'Task should not have WhatId when no AccountId provided');
        System.assert(!inserted.Description.contains('AccountId'), 'Description should not include AccountId');
    }
}