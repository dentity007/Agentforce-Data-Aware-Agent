public with sharing class InvocableActionFactory {
    public interface IAction {
        PlanModels.OrchestratorResult execute(Map<String, Object> input);
    }

    // Example DOMAIN action
    public class UpdateOpportunityStage implements IAction {
        public PlanModels.OrchestratorResult execute(Map<String, Object> input) {
            PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
            res.logs = new List<String>();
            res.warnings = new List<String>();
            res.errors = new List<String>();
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

            String product2Id = (String) input.get('Product2Id');
            Object qtyRaw = input.get('Quantity');
            Decimal quantity;

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

            String accountId = (String) input.get('AccountId');

            Task t = new Task();
            t.Subject = 'Inventory Reserve';
            t.Status = 'Not Started';
            t.Priority = 'High';
            String desc = 'Reservation Request\nProduct2Id: ' + product2Id + '\nQuantity: ' + quantity;
            if (!String.isBlank(accountId)) {
                desc += '\nAccountId: ' + accountId;
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
        if (name == 'InventoryReserve') return new InventoryReserve();
        throw new AuraHandledException('Unknown action: ' + name);
    }
}
