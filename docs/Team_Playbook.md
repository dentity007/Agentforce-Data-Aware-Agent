# Agentforce Data‑Aware Agent — Team Playbook

This playbook explains how to set up, deploy, operate, and extend the Agentforce data‑aware agent template.

## What you get
- Auto‑discovery of org schema (objects/fields/relationships) with FLS/sharing awareness
- SchemaGraph__c cache for fast lookups
- Planner + Plugin + Functions so agents can find/use data without manual mapping
- Guardrails: FLS enforcement, RestrictedField__mdt deny‑list, audit stubs
- Lead Qualification demo (Flow + Apex invocable)
- Unit tests and a GitHub Actions PR validation pipeline

## Prereqs
- Dev Hub with Scratch Orgs enabled, Salesforce CLI, GitHub repo, Connected App for JWT

## Create scratch & push
```bash
sf org login web --alias devhub --set-default-dev-hub
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf apex run --file scripts/apex/run_bootstrap.apex
sf org open
```

## Lead Qualification demo
Ask the bot: “Qualify this lead and follow up: 00Qxxxxxxxxxxxx; set status to Working”. Planner → FindFields → ExecuteSOQL → Flow (status) → Apex (task).

## CI (PRs)
JWT login → create scratch → deploy → run tests (JUnit) → upload results → delete org. Secrets: SF_CONSUMER_KEY, SF_USERNAME, SF_JWT_KEY.

## Operating
- Nightly schema refresh: OrgSchemaNightlyJob.scheduleNightly()
- On‑demand rebuild: OrgSchemaBootstrap.buildSchemaGraph()
- Add sensitive fields to RestrictedField__mdt; re‑run bootstrap

## Extending
- Add new GenAiFunction (Apex/Flow), list in Planner `<actions>`, add tests, open PR.
