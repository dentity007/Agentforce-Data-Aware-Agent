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

    // DOMAIN action: InventoryReserve
    public class InventoryReserve implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs = new List<String>();
            res.warnings = new List<String>();
            res.errors = new List<String>();

            // Required inputs
            String product2Id = (String) input.get('Product2Id');
            Object qtyRaw = input.get('Quantity');
            Decimal quantity;

            // Parse quantity (accepts string/number)
            if (qtyRaw == null) {
                res.success = false;
                res.errors.add('Missing required field: Quantity');
                return res;
            } else {
                try {
                    quantity = Decimal.valueOf(String.valueOf(qtyRaw));
                } catch (Exception e) {
                    res.success = false;
                    res.errors.add('Invalid Quantity: ' + String.valueOf(qtyRaw));
                    return res;
                }
            }

            if (String.isBlank(product2Id)) {
                res.success = false;
                res.errors.add('Missing required field: Product2Id');
                return res;
            }

            // Optional inputs
            String accountId = (String) input.get('AccountId');

            // Create a Task to represent the reservation request
            Task t = new Task();
            t.Subject = 'Inventory Reserve';
            t.Status  = 'Not Started';
            t.Priority = 'High';
            // Owner defaults to running user
            String desc = 'Reservation Request\n'
                        + 'Product2Id: ' + product2Id + '\n'
                        + 'Quantity: ' + quantity + '\n';
            if (!String.isBlank(accountId)) {
                desc += 'AccountId: ' + accountId + '\n';
                // If you want to relate the Task to an Account, set WhatId:
                // Note: Task.WhatId supports Account; Product2 is NOT a valid WhatId.
                t.WhatId = accountId;
            }
            t.Description = desc;

            try {
                insert t;
                res.success = true;
                res.logs.add('Created Task for inventory reservation: ' + t.Id);
            } catch (DmlException e) {
                res.success = false;
                res.errors.add(e.getMessage());
            }
            return res;
        }
    }

    // Factory
    public static IAction get(String name) {
        if (name == 'UpdateOpportunityStage') return new UpdateOpportunityStage();
        if (name == 'InventoryReserve') return new InventoryReserve(); // <-- add this
        // Extend: build from LLM code_artifacts in future iterations.
        throw new AuraHandledException('Unknown action: ' + name);
    }
}
