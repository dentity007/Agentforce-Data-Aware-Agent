public with sharing class InvocableActionFactory {
    public interface IAction {
        PlanModels.OrchestratorResult execute(Map<String, Object> input);
    }

    // DOMAIN: Update Opportunity Stage
    public class UpdateOpportunityStage implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs     = new List<String>();
            res.warnings = new List<String>();
            res.errors   = new List<String>();

            String oppId = (String) input.get('Id');
            String stage = (String) input.get('StageName');

            if (String.isBlank(oppId) || String.isBlank(stage)) {
                res.success = false;
                res.errors.add('Missing Id or StageName');
                return res;
            }

            try {
                update new Opportunity(Id = oppId, StageName = stage);
                res.success = true;
                res.logs.add('Updated Opportunity ' + oppId + ' to stage ' + stage);
            } catch (DmlException ex) {
                res.success = false;
                res.errors.add(ex.getMessage());
            }
            return res;
        }
    }

    // DOMAIN: InventoryReserve (portable — represented as a Task)
    public class InventoryReserve implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs     = new List<String>();
            res.warnings = new List<String>();
            res.errors   = new List<String>();

            // Required inputs
            String product2Id = (String) input.get('Product2Id');
            Object qtyRaw     = input.get('Quantity');
            Decimal quantity;

            if (String.isBlank(product2Id)) {
                res.success = false;
                res.errors.add('Missing required field: Product2Id');
                return res;
            }
            if (qtyRaw == null) {
                res.success = false;
                res.errors.add('Missing required field: Quantity');
                return res;
            }
            try {
                quantity = Decimal.valueOf(String.valueOf(qtyRaw));
            } catch (Exception e) {
                res.success = false;
                res.errors.add('Invalid Quantity: ' + String.valueOf(qtyRaw));
                return res;
            }

            // Optional input
            String accountId = (String) input.get('AccountId');

            // Create a Task to represent the reservation request
            Task t = new Task();
            t.Subject  = 'Inventory Reserve';
            t.Status   = 'Not Started';
            t.Priority = 'High';

            String body = 'Reservation Request' + '\n'
                        + 'Product2Id: ' + product2Id + '\n'
                        + 'Quantity: '   + String.valueOf(quantity) + '\n';

            if (!String.isBlank(accountId)) {
                // If you want to relate the Task to an Account, set WhatId
                t.WhatId = accountId;
                body += 'AccountId: ' + accountId + '\n';
            }
            t.Description = body;

            try {
                insert t;
                res.success = true;
                res.logs.add('Created Task for inventory reservation: ' + t.Id);
            } catch (DmlException ex) {
                res.success = false;
                res.errors.add(ex.getMessage());
            }
            return res;
        }
    }

    // Factory
    public static IAction get(String name) {
        if (name == 'UpdateOpportunityStage') return new UpdateOpportunityStage();
        if (name == 'InventoryReserve')       return new InventoryReserve();
        throw new AuraHandledException('Unknown action: ' + name);
    }
}
