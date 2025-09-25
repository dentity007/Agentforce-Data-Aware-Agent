# 📘 Master Summary & Roadmap

## 1. What This Project Is
A Salesforce DX template for **Agentforce data-aware agents** that:
- Auto-discovers org schema (objects, fields, relationships).
- Enforces **FLS/sharing** on every data operation.
- Executes **safe actions** (SOQL, Flow, Apex).
- Provides two demos:
  - **Lead Qualification** (update Leads, Tasks, statuses).
  - **Personal Shopping Assistant** (catalog, inventory, loyalty, cart).
- Integrates **Salesforce Knowledge grounding** (Data Library + Apex fallback).
- Ships with **prompt templates, unit tests, CI setup, and docs**.

---

## 2. New Architectural Principles
- **Schema slicing, not full schema** → Only relevant objects/fields sent to LLM, **PII redacted/masked**.
- **Two-stage flow**:
  1) Schema determination (discover + slice)
  2) Functionality determination & execution (plan + codegen + orchestrate)
- **Structured outputs only** → JSON in/out; `plan.json` + `code_artifacts`. No raw DSL.
- **Dynamic method generation** → CRUD + domain actions created on the fly (invocable pattern).
- **Confirm/reject checkpoint** prior to execution; **Business Rules Agent** coupling.
- **Optional ensemble** for plan/code validation.
- **Portability-first** across orgs via re-slicing.

---

## 3. Deliverables (DoD)
- **One-Pager** ("What it does" & "Value") with slicing/privacy diagram.
- **Metadata Discovery (Apex)** → enumerates schema, exports JSON, runs on ≥2 orgs.
- **Schema Slicer** → outputs `schema_slice.json`, flags/removes PII, logs token budget.
- **LLM I/O Contract** → JSON in/out; fixtures versioned.
- **Planner** → `plan.json` with actions, deps, CRUD/domain ops, checkpoint text.
- **CodeGen** → invocable Apex + SOQL; compiles; ≥70% unit test coverage.
- **Action Orchestrator** → executes plan.json; rules coupling; approval checkpoint.
- **Privacy & Redaction Guard** → policy tests + evidence logs.
- **Portability Playbook** → runs E2E on ≥2 orgs with no code edits (re-slice & re-plan).
- **Demo Scenarios** → Inventory Check & Loan Eligibility.
- **Submission Pack** (by Oct 31) → one-pager, 3–5 min video, repo link, benefits slide.

---

## 4. Validation Metrics
- **Slicing**: ≤15 tables, ≤120 fields; ≥95% task success; **0 PII leakage**.
- **Two-stage flow**: ≥90% compile rate; human confirmation before exec.
- **Dynamic methods**: new domain ops added via template/prompt (no code release).
- **Structured outputs**: 100% machine-readable; human summary auto-generated.
- **Rules coupling**: runtime attach; no regen required.
- **Ensemble (optional)**: ≥50% seeded issues caught.
- **Portability**: runs in multiple orgs via re-slicing/re-planning.
- **DX**: new org → first run in ≤15 minutes.

---

## 5. Evidence to Capture
- `schema_slice.json` (pre/post redaction + token counts)
- `plan.json` + checkpoint text
- Generated Apex + SOQL + compile logs
- Unit test results + coverage
- Privacy guard logs + red-team results
- Ensemble validation logs (if enabled)
- Demo runbook + screenshots/video

---

## 6. Two-Stage Flow (ASCII Diagram)


User Goal (e.g., Loan Eligibility)
|
v
Metadata Discovery
(all objects & fields)
|
v
Schema Slicer
(schema_slice.json)

Relevant fields only

PII redacted

Token budget logged
|
v
Planner
(plan.json with actions,
dependencies, checkpoint)
|
v
CodeGen
(Apex/SOQL + tests, ≥70% coverage)
|
v
Action Orchestrator

Enforce FLS/sharing

Confirm/reject

Business Rules Agent
|
v
Execution Result
(Lead update, Inventory check, Loan eligibility)


---

## 7. Expansion Roadmap
- **Service Cloud**: Case Triage & Next-Best-Action (Entitlements, KB, SLA).
- **Security**: deny-by-default SOQL builder; row-level sharing tests.
- **Knowledge**: boosted retrieval; citation renderer UI.
- **Shopping**: inventory reservation; abandon-cart follow-ups.
- **DX**: scripted setup, sample data packs, minimal vs full manifests.
- **Observability**: audit log object; Platform Events.
- **LWC Agent Console** to run prompts, view slices, plans, citations, actions.