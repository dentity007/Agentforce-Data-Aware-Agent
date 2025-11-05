# Agentforce Data-Aware Agent POC

[![Agentforce: Data‑Aware Ready](https://img.shields.io/badge/Agentforce-Data%E2%80%91Aware%20Ready-00A1E0)](docs/data-library/SETUP.md)
[![Latest Release](https://img.shields.io/github/v/release/dentity007/Agentforce-Data-Aware-Agent)](https://github.com/dentity007/Agentforce-Data-Aware-Agent/releases/latest)
[![Test Coverage](https://img.shields.io/badge/tests-100%25%20pass-green)](https://github.com/dentity007/Agentforce-Data-Aware-Agent)

An intelligent Salesforce agent that combines **schema discovery**, **dynamic action routing**, **input validation**, and **knowledge-grounded responses** for enterprise-grade AI automation.

## 🎯 Core Capabilities

### **Dynamic Schema Discovery**
- Auto-discovers org metadata (objects, fields, relationships)
- FLS/sharing-aware data operations with governance
- Portable across different Salesforce orgs

### **Intelligent Action Routing**
- **Smart Goal Analysis**: Automatically routes requests based on keywords
  - *"reserve inventory"* → `InventoryReserve` action
  - *"update opportunity"* → `UpdateOpportunityStage` action
- **Extensible Framework**: Easy to add new routing rules

### **Checkpoint Guard System**
- **Preflight Validation**: Verifies all required inputs before database operations
- **Type Safety**: Validates numeric fields, required vs optional fields
- **Error Prevention**: Blocks invalid data from reaching the database
- **Clear Messaging**: Provides specific error messages for validation failures

### **Knowledge-Grounded Responses**
- **Data Library Integration**: Uses Salesforce Knowledge for RAG
- **Fallback Mechanisms**: Apex-based knowledge retrieval when Data Library unavailable
- **Citations & Attribution**: Source tracking for grounded responses

## 🤖 Available Actions

The agent supports **dynamic DOMAIN actions** that are automatically routed based on user goals:

### **InventoryReserve** (Primary Action)
- **Trigger**: Goals containing "inventory", "stock", or "reserve"
- **Function**: Creates high-priority Tasks to represent inventory reservations
- **Fields**: `Product2Id` (required), `Quantity` (required, numeric > 0), `AccountId` (optional)
- **Validation**: Checkpoint guard ensures all inputs are valid before database operations

### **UpdateOpportunityStage** (Default Action)
- **Trigger**: All other goals (default routing)
- **Function**: Updates Opportunity stage with FLS/sharing compliance
- **Fields**: `Id` (required), `StageName` (required)
- **Validation**: Standard Salesforce validation + guardrails

## 📝 Structured Prompt Templates

The project includes **reusable prompt templates** for consistent agent behavior:

#### **LeadQualification.prompt**
- **Purpose**: Intelligent lead qualification with dynamic schema discovery
- **Features**: Picklist-aware status updates, task creation, FLS compliance
- **Use Case**: Sales automation, lead scoring workflows

#### **PersonalShoppingRecommendation.prompt**
- **Purpose**: E-commerce product recommendations with inventory awareness
- **Features**: Price filtering, stock checking, knowledge-grounded suggestions
- **Use Case**: Customer service, personalized shopping assistance

#### **LoanEligibility.prompt**
- **Purpose**: Financial loan eligibility assessment with compliance
- **Features**: PII protection, risk assessment, automated decision workflows
- **Use Case**: Financial services, loan processing automation

#### **InventoryCheck.prompt**
- **Purpose**: Real-time inventory verification and stock management
- **Features**: Dynamic catalog checking, stock level monitoring, automated alerts
- **Use Case**: E-commerce, supply chain management

### **Key Benefits:**
- 🔍 **Schema-Aware**: No hard-coded field names or SOQL
- 🛡️ **Governed**: FLS and sharing rule compliance + checkpoint validation
- 📚 **Knowledge-Integrated**: Works with Data Libraries and Knowledge articles
- 🔄 **Portable**: Adapts to different org configurations
- 📋 **Structured Output**: JSON blueprints for safe, auditable operations
- ⚡ **Intelligent Routing**: Automatic action selection based on goal analysis

**[Complete Template Guide](docs/prompt-templates/README.md)**

## 🚀 Quick Start

### Prerequisites
- **Salesforce CLI** installed (`sf`)
- **Dev Hub** access for scratch orgs
- **Git** for version control

### Development Setup

```bash
# Clone the repository
git clone https://github.com/dentity007/Agentforce-Data-Aware-Agent.git
cd agentforce-data-aware

# Authenticate with Dev Hub
sf org login web --alias devhub --set-default-dev-hub

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10

# Deploy and setup
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf org open
```

### Test the Agent

Try these example goals to see intelligent routing in action:

```
"Reserve 5 units of inventory for product ABC123"
→ Automatically routes to InventoryReserve action
→ Validates Quantity > 0, creates Task

"Update the opportunity stage to Closed Won"
→ Routes to UpdateOpportunityStage action
→ Updates Opportunity with governance
```

### Development Tools

This project includes a scaffolding script for common development tasks:

```bash
# Make the script executable (one-time setup)
chmod +x scripts/scaffold.sh

# Setup development environment
./scripts/scaffold.sh setup dev

# Create new components
./scripts/scaffold.sh create class MyNewClass
./scripts/scaffold.sh create trigger MyTrigger Account
./scripts/scaffold.sh create lwc myComponent

# Deploy and test
./scripts/scaffold.sh deploy
./scripts/scaffold.sh test
```

```bash
# Authenticate
sf org login web --alias devhub --set-default-dev-hub

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10

# Deploy and setup
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf org open

# Test intelligent routing
# "Reserve 5 units of inventory for product ABC" → InventoryReserve action
# "Update opportunity stage to Closed Won" → UpdateOpportunityStage action
```

## 🧪 Comprehensive Testing

This project maintains **100% test pass rate** with comprehensive coverage across all components:

```bash
# Run all tests (40+ Apex classes, 8 dedicated test suites)
sf apex run test --result-format human --code-coverage --wait 30

# Run specific test suites
sf apex run test --tests InventoryReserveTests --result-format human --wait 10
sf apex run test --tests PlannerRouteTests --result-format human --wait 10
sf apex run test --tests OrchestratorCheckpointGuardTests --result-format human --wait 10
sf apex run test --tests AgentLeadActionTests,AgentQueryTests,AgentSchemaTests --result-format human --wait 10

# Run with coverage requirements
sf apex run test --result-format human --code-coverage --coverage-threshold 75 --wait 30
```

### **Test Coverage Breakdown:**

#### **Core Functionality Tests (100% pass rate)**
- **InventoryReserveTests** (3 tests): Task creation, input validation, optional fields
- **PlannerRouteTests** (2 tests): Intelligent routing for inventory vs opportunity goals
- **OrchestratorCheckpointGuardTests** (3 tests): Input validation before database operations

#### **Integration Tests**
- **AgentLeadActionTests**: Lead qualification workflows
- **AgentQueryTests**: Safe SOQL execution with FLS/sharing
- **AgentSchemaTests**: Dynamic schema discovery
- **MetadataDiscoveryTests**: Object/field metadata operations
- **PlannerAndOrchestratorTests**: End-to-end orchestration
- **PrivacyGuardTests**: PII redaction and data protection
- **SchemaSlicerTests**: Metadata slicing and filtering

#### **Validation Features**
- ✅ **Checkpoint Guards**: Input validation prevents invalid database operations
- ✅ **FLS Compliance**: All operations respect field-level security
- ✅ **Sharing Rules**: Data access follows org sharing configuration
- ✅ **Error Handling**: Comprehensive error messages and graceful failures

### Core Apex Classes (40+ Classes)
- **Intelligent Routing**: `Planner` (goal analysis), `ActionOrchestrator` (checkpoint guards)
- **Schema Discovery**: `MetadataDiscovery`, `SchemaSlicer`, `OrgSchemaBootstrap`
- **Data Operations**: `SOQLBuilder`, `SafeQueryApex`, `DataCloudQueryApex`
- **Security & Governance**: `FLS`, `PrivacyGuard`, `JSONUtil`
- **DOMAIN Actions**: `InvocableActionFactory`, `DomainActionRegistry`
- **Business Logic**: `LeadQualificationAction`, `LeadScoreService`, `FollowUpApex`
- **Knowledge Integration**: `KnowledgeRetrieverApex` (RAG fallback)
- **Testing**: Comprehensive test suite with 8 test classes (100% pass rate)

### GenAI Functions (11 Functions)
- **Data Operations**: `ExecuteSOQL`, `FindFields`, `FindObjects`, `FindRelationshipPath`
- **AI Actions**: `QueryDataCloud`, `RunFlow`, `TriggerFollowUpAction`, `UpdateLeadStatusAction`
- **Business Logic**: `CheckInventoryAction`, `DiscoverMetadataAction`, `RetrieveKnowledgeSnippets`

### Prompt Templates (5 Templates)
- **LeadQualification**: Sales automation with schema awareness
- **PersonalShoppingRecommendation**: E-commerce with inventory checking
- **LoanEligibility**: Financial services with PII protection
- **InventoryCheck**: Supply chain management
- **DataAwarePrompt**: General-purpose data operations

## 📚 Documentation

### Project Overview
- **[Master Roadmap](docs/master-roadmap.md)**: Complete project summary, architecture, and roadmap
- **[One-Pager](docs/one-pager.md)**: Executive summary of capabilities and value proposition
- **[LLM I/O Contract](docs/README-LLM-IO.md)**: Technical specification for AI model interfaces

### Agentforce Data-Aware Agent
- **[Team Playbook](docs/Team_Playbook.md)**: Complete setup and operations
- **[Solution Architecture](docs/Solution_Architecture.md)**: Technical deep-dive
- **[Quick Start](docs/Quick_Start_2Pager.md)**: Executive summary

### Personal Shopping Assistant
- **[Conversation Demo](docs/conversation-demo.md)**: Sample bot interactions
- **[Session Guide](docs/today-session.md)**: Technical implementation details

### Knowledge-Grounded Capabilities
- **[Data Library Setup](docs/data-library/SETUP.md)**: Configure Agentforce Data Libraries
- **[Planner Instructions](docs/planner/PLANNER_INSTRUCTIONS.md)**: Knowledge integration guidelines
- **[Knowledge Integration Guide](docs/KNOWLEDGE_INTEGRATION_GUIDE.md)**: Complete technical implementation
- **[Knowledge Addon README](README_DATA_AWARE_ADDON.md)**: Complete addon documentation

### Prompt Templates
- **[Prompt Templates Guide](docs/prompt-templates/README.md)**: Reusable schema-aware templates
- **[Lead Qualification Template](docs/prompt-templates/README.md#leadqualificationprompt)**: Sales automation
- **[Shopping Recommendation Template](docs/prompt-templates/README.md#personalshoppingrecommendationprompt)**: E-commerce assistance

## 🧪 Testing

```bash
# Run all tests (40+ Apex classes, 8 dedicated test suites, 100% pass rate)
sf apex run test --result-format human --code-coverage --wait 30

# Run specific test suites
sf apex run test --tests InventoryReserveTests,PlannerRouteTests,OrchestratorCheckpointGuardTests --result-format human --wait 10
sf apex run test --tests AgentLeadActionTests,AgentQueryTests,AgentSchemaTests --result-format human --wait 10
sf apex run test --tests MetadataDiscoveryTests,PlannerAndOrchestratorTests,PrivacyGuardTests,SchemaSlicerTests --result-format human --wait 10

# Run with coverage requirements
sf apex run test --result-format human --code-coverage --coverage-threshold 75 --wait 30
```

## 🚀 Automated Releases

This project uses **semantic versioning** with automated release management:

### **How It Works**
- **Conventional Commits**: Version bumps based on commit message prefixes:
  - `feat:` → Minor version bump (1.0.0 → 1.1.0)
  - `fix:` → Patch version bump (1.0.0 → 1.0.1)
  - `BREAKING CHANGE:` → Major version bump (1.0.0 → 2.0.0)
- **Automated Process**: GitHub Actions automatically creates releases on pushes to `main`/`master`
- **Changelog Generation**: Release notes are automatically generated from commit messages

### **Release Process**
1. **Make Changes**: Commit with conventional commit format
2. **Push to Main**: Triggers automated release workflow
3. **Automatic Release**: Version bump, tag creation, and GitHub release
4. **Changelog Update**: Release notes added to CHANGELOG.md

### **Example Commits**
```bash
git commit -m "feat: add intelligent inventory routing"
git commit -m "fix: resolve checkpoint guard validation bug"
git commit -m "feat: implement knowledge-grounded responses

BREAKING CHANGE: updated action interface"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and updates.

## 🆘 Support

- Check documentation in `docs/` folder
- Review GitHub Actions workflow logs
- Open issues for bugs or feature requests
