public with sharing class Planner {
    /**
     * Build a plan based on the goal + schema slice + constraints.
     * Routes to DOMAIN actions:
     *  - InventoryReserve  when goal mentions inventory/stock/reserve
     *  - UpdateOpportunityStage otherwise (example default)
     */
    public static PlanModels.Plan producePlan(
        Map<String, Object> slice,
        String goal,
        Map<String, Object> constraints
    ) {
        String g = (goal == null) ? '' : goal.toLowerCase();

        // Base plan scaffolding
        PlanModels.Plan p = new PlanModels.Plan();
        p.capabilities   = new List<String>{ 'CRUD', 'DOMAIN' };
        p.steps          = new List<String>{ 'Analyze goal', 'Choose actions', 'Assemble dependencies', 'Generate checkpoint' };
        p.dependencies   = new List<String>{ 'FLS', 'Sharing' };

        // Route by goal keywords
        if (g.contains('inventory') || g.contains('stock') || g.contains('reserve')) {
            // ========= InventoryReserve =========
            PlanModels.ActionDef a = new PlanModels.ActionDef();
            a.name           = 'InventoryReserve';
            a.type           = 'DOMAIN';
            a.sobjectApiName = 'Task'; // portable representation
            a.fields = new Map<String, Object>{
                'Product2Id' => null,
                'Quantity'   => null,
                'AccountId'  => null // optional
            };
            a.guardrails = new Map<String, Object>{
                'requireFLS'      => true,
                'requireSharing'  => true,
                'optionalFields'  => (Object) new List<String>{ 'AccountId' },
                'numericFields'   => (Object) new List<String>{ 'Quantity' }
            };
            p.actions = new List<PlanModels.ActionDef>{ a };
            p.checkpointText = 'I will create a high-priority Task to reserve inventory. Proceed?';
        } else {
            // ========= Default: UpdateOpportunityStage =========
            PlanModels.ActionDef a = new PlanModels.ActionDef();
            a.name           = 'UpdateOpportunityStage';
            a.type           = 'DOMAIN';
            a.sobjectApiName = 'Opportunity';
            a.fields = new Map<String, Object>{
                'Id'        => null,
                'StageName' => null
            };
            a.guardrails = new Map<String, Object>{
                'requireFLS'     => true,
                'requireSharing' => true
            };
            p.actions = new List<PlanModels.ActionDef>{ a };
            p.checkpointText = 'I will update an Opportunity stage based on your instructions. Proceed?';
        }

        return p;
    }
}
