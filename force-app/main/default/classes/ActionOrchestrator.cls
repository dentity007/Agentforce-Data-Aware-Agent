public with sharing class ActionOrchestrator {

    @AuraEnabled
    public static PlanModels.OrchestratorResult run(PlanModels.Plan plan, Map<String, Object> userInputs, Boolean confirmed) {
        PlanModels.OrchestratorResult res = new PlanModels.OrchestratorResult();
        res.logs     = new List<String>();
        res.warnings = new List<String>();
        res.errors   = new List<String>();

        // Checkpoint confirmation
        if (!confirmed) {
            res.success = false;
            res.warnings.add('Execution not confirmed');
            return res;
        }

        // Execute each action with preflight checks
        for (PlanModels.ActionDef a : plan.actions) {
            // Pull provided inputs for this action
            Map<String, Object> provided = (userInputs != null)
                ? (Map<String, Object>) userInputs.get(a.name)
                : null;

            // Preflight guard: required/optional/numeric validation BEFORE DML
            List<String> guardErrors = validateInputs(a, provided);
            if (!guardErrors.isEmpty()) {
                res.success = false;
                res.errors.addAll(guardErrors);
                res.logs.add('Blocked by checkpoint guard for action: ' + a.name);
                return res;
            }

            // (Hook) Business Rules Agent could be invoked here (pre conditions)
            // if (Rules.shouldBlock(a, provided)) ...

            // Dispatch to the concrete implementation
            InvocableActionFactory.IAction impl = InvocableActionFactory.get(a.name);
            PlanModels.OrchestratorResult step = impl.execute(provided);

            // Bubble up step results
            if (step == null) {
                res.success = false;
                res.errors.add('Action returned null result: ' + a.name);
                return res;
            }
            if (!step.success) {
                res.success = false;
                if (step.errors != null) res.errors.addAll(step.errors);
                if (step.warnings != null) res.warnings.addAll(step.warnings);
                if (step.logs != null) res.logs.addAll(step.logs);
                return res;
            }
            if (step.logs != null) res.logs.addAll(step.logs);
            if (step.warnings != null) res.warnings.addAll(step.warnings);
        }

        res.success = true;
        return res;
    }

    // ---------- Helpers ----------

    /** Validate required fields + simple numeric checks before execution. */
    private static List<String> validateInputs(PlanModels.ActionDef a, Map<String, Object> provided) {
        List<String> errors = new List<String>();
        if (a == null) {
            errors.add('Missing action definition.');
            return errors;
        }
        if (provided == null) {
            errors.add('No input provided for action: ' + a.name);
            return errors;
        }

        // Optional and numeric sets from guardrails
        Set<String> optional = new Set<String>();
        Set<String> numeric  = new Set<String>();
        if (a.guardrails != null) {
            if (a.guardrails.containsKey('optionalFields') && a.guardrails.get('optionalFields') != null) {
                for (Object f : (List<Object>) a.guardrails.get('optionalFields')) optional.add(String.valueOf(f));
            }
            if (a.guardrails.containsKey('numericFields') && a.guardrails.get('numericFields') != null) {
                for (Object f : (List<Object>) a.guardrails.get('numericFields')) numeric.add(String.valueOf(f));
            }
        }

        // Required presence (anything in a.fields not listed optional)
        if (a.fields != null) {
            for (String fieldName : a.fields.keySet()) {
                if (optional.contains(fieldName)) continue;
                if (!provided.containsKey(fieldName)) {
                    errors.add('Missing required field: ' + fieldName + ' (action ' + a.name + ')');
                    continue;
                }
                Object v = provided.get(fieldName);
                if (v == null || String.valueOf(v).trim() == '') {
                    errors.add('Required field is empty: ' + fieldName + ' (action ' + a.name + ')');
                }
            }
        }

        // Simple numeric checks (Decimal parse)
        for (String nf : numeric) {
            if (!provided.containsKey(nf)) {
                // If it's optional but listed numeric and missing, skip; otherwise error already captured above.
                continue;
            }
            Object raw = provided.get(nf);
            try {
                Decimal d = Decimal.valueOf(String.valueOf(raw));
                // Disallow <= 0 as a common-sense default
                if (d <= 0) {
                    errors.add('Numeric field must be > 0: ' + nf + ' (action ' + a.name + ')');
                }
            } catch (Exception e) {
                errors.add('Invalid numeric value for ' + nf + ': ' + String.valueOf(raw) + ' (action ' + a.name + ')');
            }
        }

        return errors;
    }
}
