# Agentforce “Data-Aware + Knowledge-Grounded” Add-On

This add-on complements your data-aware agent template by (A) integrating **Agentforce Data Libraries** (recommended) and (B) providing a **fallback Apex action** that retrieves grounded snippets from Salesforce Knowledge when a Data Library isn’t configured.

## What’s included
- `docs/data-library/SETUP.md` — step-by-step guide to create a Data Library and attach it to your agent via **Answer Questions with Knowledge**.
- `docs/planner/PLANNER_INSTRUCTIONS.md` — copy-paste text for your planner/topic to use the Data Library action or the fallback Apex action.
- `force-app/main/default/classes/KnowledgeRetrieverApex.cls` — invocable Apex action that returns short knowledge snippets and lightweight citations.
- `force-app/main/default/classes/KnowledgeRetrieverApex.cls-meta.xml` — metadata descriptor.
- `force-app/main/default/classes/KnowledgeRetrieverApex_Test.cls` — smoke test to keep CI green.
- `force-app/main/default/promptTemplates/*.prompt` — project-scoped prompts (schema-aware, SOQL-free blueprints).
- `manifest/package.xml` — optional manifest for deploying just these classes.

## Quick start (deploy the Apex fallback)
```bash
sf project deploy start --source-dir force-app/main/default/classes --wait 30
# Or using the included manifest:
sf project deploy start --manifest manifest/package.xml --wait 30
```
