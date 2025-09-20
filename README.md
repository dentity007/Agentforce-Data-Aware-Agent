# Agentforce Data-Aware Agent (SFDX)

[![PR Validate (Scratch Org)](https://github.com/dentity007/Agentforce-Data-Aware-Agent/actions/workflows/pr-validate.yml/badge.svg)](https://github.com/dentity007/Agentforce-Data-Aware-Agent/actions/workflows/pr-validate.yml)

## Description

The Agentforce Data-Aware Agent is a comprehensive Salesforce DX template designed to build AI-powered agents that intelligently interact with Salesforce data. This project enables agents to automatically discover your org's schema, understand relationships, and perform safe, governed operations while respecting Field-Level Security (FLS) and sharing rules.

Key capabilities include:
- **Auto-schema discovery**: Agents dynamically learn about objects, fields, and relationships without manual configuration.
- **Governance-first**: Built-in FLS enforcement, deny-lists, and audit trails ensure secure and compliant data access.
- **Extensible architecture**: Modular GenAI functions, planners, and plugins for easy customization.
- **Production-ready**: Includes CI/CD pipelines, unit tests, and operational tooling.

This template demonstrates a lead qualification use case but can be extended for various business processes.

## Features

- **Intelligent Schema Navigation**: Cached schema graph for fast, accurate data discovery.
- **Safe Data Operations**: FLS-aware queries, Flows, and Apex actions running under user context.
- **Audit & Compliance**: Comprehensive logging and rollback capabilities.
- **Multi-Channel Support**: Works with Lightning, Slack, and other Salesforce surfaces.
- **Performance Optimized**: Efficient queries with limits on rows, fields, and joins.
- **CI/CD Ready**: GitHub Actions for PR validation with scratch orgs.

## Architecture

The solution follows a layered architecture:

- **Agent Layer**: Bot definitions, planner bundles, and prompt templates.
- **Intelligence Layer**: Metadata navigator plugin and schema graph caching.
- **Execution Layer**: GenAI functions for SOQL execution, Flow runs, and domain-specific actions.
- **Governance Layer**: Restricted field metadata, audit services, and nightly refresh jobs.

For detailed architecture diagrams and sequences, see [docs/diagrams/](docs/diagrams/).

## Prerequisites

- Salesforce Dev Hub with Scratch Orgs enabled
- Salesforce CLI (`sf`) installed
- GitHub repository for CI/CD
- Connected App for JWT authentication (for CI)

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/dentity007/Agentforce-Data-Aware-Agent.git
   cd agentforce-data-aware
   ```

2. **Authenticate with Dev Hub**:
   ```bash
   sf org login web --alias devhub --set-default-dev-hub
   ```

3. **Create and deploy to Scratch Org**:
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10
   sf project deploy start --ignore-conflicts --wait 30
   sf org assign permset --name GenAIAgentPermission
   sf apex run --file scripts/apex/run_bootstrap.apex
   sf org open
   ```

## Usage

### Lead Qualification Demo

Interact with the bot: "Qualify this lead and follow up: 00Qxxxxxxxxxxxx; set status to Working"

The agent will:
1. Discover relevant fields and relationships
2. Execute safe SOQL queries
3. Update lead status via Flow
4. Create follow-up tasks via Apex

### Extending the Agent

- Add new GenAI functions in `force-app/main/default/genAiFunctions/`
- Update the planner bundle to include new actions
- Modify prompts in `force-app/main/default/promptTemplates/`
- Add tests and update CI

## Documentation

- **[Team Playbook](docs/Team_Playbook.md)**: Complete setup, deployment, and operation guide
- **[Quick Start 2-Pager](docs/Quick_Start_2Pager.md)**: Executive summary for pilots
- **[Solution Architecture](docs/Solution_Architecture.md)**: Technical deep-dive
- **[Diagrams](docs/diagrams/)**: Visual architecture, flows, and sequences

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes and add tests
4. Run tests: `sf apex run test --wait 10 --resultformat human`
5. Submit a pull request

PRs are validated automatically with scratch org deployment and test execution.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions:
- Check the [Team Playbook](docs/Team_Playbook.md) for common setup problems
- Open an issue on GitHub
- Review audit logs in Salesforce for runtime issues
