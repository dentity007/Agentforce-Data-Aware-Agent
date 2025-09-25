# 📝 Agentforce Data-Aware Agent — One-Pager

## What It Does
Enables secure, schema-aware AI agents inside any Salesforce org:
- **Discovers & slices metadata** to only what's relevant (≤15 objects, ≤120 fields).
- **Redacts PII** before prompts/logs.
- **Two-stage flow**: (1) Schema determination → (2) Plan + CodeGen + Orchestrate.
- **Structured outputs only** (`plan.json` + code artifacts), no raw DSL.
- **Dynamic actions**: CRUD & domain methods generated and compiled as invocables.
- **Safe execution**: FLS/sharing enforced; confirmation checkpoint; Business Rules Agent coupling.
- **Demos**: Lead Qualification, Personal Shopping; plus Inventory Check & Loan Eligibility.
- **Portable**: Re-slice/re-plan across orgs without code edits.

## Value
- **Privacy-first**: Zero PII leakage; proven via red-team tests.
- **Trustworthy AI**: Governed actions, ≥70% tests, human checkpoints.
- **Portable**: Works across orgs with re-slice/re-plan.
- **Auditable**: Slice, plan, actions logged; generated code versioned.
- **Enterprise-ready**: Knowledge grounding + rules + safe actions.
- **Fast onboarding**: New org to first run in ≤15 minutes.
- **Business impact**: Automates lead ops, inventory checks, loan eligibility decisions.

### Two-Stage Flow (ASCII)


Goal -> Discovery -> Slice -> Planner -> CodeGen -> Orchestrator -> Result


_See also: `docs/master-roadmap.md` and `docs/README-LLM-IO.md`_.