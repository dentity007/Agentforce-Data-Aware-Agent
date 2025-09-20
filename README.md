# Agentforce Data‑Aware Agent (SFDX)

**What**: A Salesforce DX template for Agentforce AI agents that auto‑discover org schema and act safely (FLS/sharing aware).

## Quick Start
```bash
sf org login web --alias devhub --set-default-dev-hub
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf apex run --file scripts/apex/run_bootstrap.apex
sf org open
```

## CI Badge
[![PR Validate (Scratch Org)](https://github.com/dentity007/Agentforce-Data-Aware-Agent/actions/workflows/pr-validate.yml/badge.svg)](https://github.com/dentity007/Agentforce-Data-Aware-Agent/actions/workflows/pr-validate.yml)

## Documentation
- [Team Playbook](docs/Team_Playbook.md)
- [Quick Start 2‑Pager](docs/Quick_Start_2Pager.md)
- [Solution Architecture](docs/Solution_Architecture.md)
- Diagrams: `docs/diagrams/`
