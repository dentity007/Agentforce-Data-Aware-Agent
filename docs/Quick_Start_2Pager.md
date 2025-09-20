# Agentforce Data‑Aware Agent — Quick Start (Exec & PM 2‑Pager)

**Why**: Faster ops, no manual field mapping, governed (FLS, deny‑list), auditable.  
**Pilot metric ideas**: +30% triage speed, +15% timely follow‑ups, <1% permission violations.

## Scope (4–6 weeks)
- Use case: Lead qualification & follow‑up
- Surfaces: Lightning / Slack (optional)
- Data: Lead (+ related minimal fields), PII deny‑listed

## RACI (pilot)
Sponsor (A), PM (A), Admin (R), Dev (R), Security (C), Sales Ops (C).

## Environments
Dev Hub + Scratch (CI on PRs) → UAT Sandbox → Production

## Checklist
Week 0: GitHub secrets; deny‑list review.  
Week 1: Scratch, deploy, bootstrap, smoke test.  
Week 2–3: Tune prompts/actions; iterate.  
Week 4: UAT metrics; approve; Prod.

## How it works (plain English)
Planner finds objects/fields/paths from a cached schema graph, then calls safe queries/Flows/Apex under user permissions. Only a small schema slice is sent with prompts; sensitive fields are blocked.

## Governance & risk
FLS enforcement; RestrictedField__mdt; audit stubs; rollback via PRs/tags.
