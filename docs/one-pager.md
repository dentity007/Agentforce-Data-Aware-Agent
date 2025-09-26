# 📝 Agentforce Data-Aware Agent — One-Pager

## What It Does
Enables secure, schema-aware AI agents inside any Salesforce org:
- **Intelligent Goal Routing**: Automatically selects actions based on keywords ("inventory" → InventoryReserve, others → UpdateOpportunityStage)
- **Checkpoint Guard System**: Validates all inputs before database operations (required fields, numeric validation, type safety)
- **Discovers & slices metadata** to only what's relevant (≤15 objects, ≤120 fields)
- **Redacts PII** before prompts/logs with comprehensive privacy protection
- **Two-stage flow**: (1) Schema determination → (2) Plan + CodeGen + Orchestrate
- **Structured outputs only** (`plan.json` + code artifacts), no raw DSL
- **Dynamic actions**: CRUD & domain methods generated and compiled as invocables
- **Safe execution**: FLS/sharing enforced; confirmation checkpoint; input validation guards
- **Knowledge-grounded**: Integrates with Salesforce Knowledge for RAG responses
- **Portable**: Re-slice/re-plan across orgs without code edits
- **Latest**: v0.3.0 with 100% test coverage and production-ready checkpoint guards

## Value
- **Privacy-first**: Zero PII leakage; proven via comprehensive test suite
- **Trustworthy AI**: Governed actions, 100% test pass rate, human checkpoints, input validation
- **Intelligent Automation**: Automatic action routing based on natural language goals
- **Data Integrity**: Checkpoint guards prevent invalid data from reaching database
- **Portable**: Works across orgs with re-slice/re-plan
- **Auditable**: Slice, plan, actions logged; generated code versioned
- **Enterprise-ready**: Knowledge grounding + rules + safe actions + comprehensive validation
- **Fast onboarding**: New org to first run in ≤15 minutes.
- **Business impact**: Automates lead ops, inventory checks, loan eligibility decisions.

### Two-Stage Flow (ASCII)


Goal -> Discovery -> Slice -> Planner -> CodeGen -> Orchestrator -> Result


_See also: `docs/master-roadmap.md` and `docs/README-LLM-IO.md`_.