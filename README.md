# Unified Agentforce Data-Aware Solutions

[![Agentforce: Data‑Aware Ready](https://img.shields.io/badge/Agentforce-Data%E2%80%91Aware%20Ready-00A1E0)](docs/data-library/SETUP.md)

This repository contains **two complementary Salesforce DX projects** that demonstrate advanced AI agent capabilities with data awareness, schema discovery, and governance.

## 🎯 Projects Overview

### 1. **Agentforce Data-Aware Agent** (Lead Qualification)
- **Purpose**: Intelligent lead qualification and follow-up automation
- **Key Features**:
  - Auto-discovers org schema (objects, fields, relationships)
  - FLS/sharing-aware data operations
  - Safe SOQL execution with governance
  - Lead status updates and task creation
- **Use Case**: Sales operations, lead management

### 2. **Personal Shopping Assistant** (E-commerce Bot)
- **Purpose**: AI-powered shopping assistant with dynamic inventory management
- **Key Features**:
  - Dynamic product catalog discovery
  - Real-time inventory checking
  - Personalized recommendations
  - Customer loyalty integration
  - Shopping cart management
- **Use Case**: E-commerce, customer service

## 🧠 Knowledge-Grounded Capabilities

Both agents now include **knowledge-grounded responses** using Salesforce Knowledge for RAG (Retrieval-Augmented Generation):

### **Two Integration Paths:**

#### **Path A: Agentforce Data Library (Recommended)**
- Create a Data Library in Setup → Agentforce Data Library
- Attach to agent's **"Answer Questions with Knowledge"** action
- Automatic grounding with articles, files, and web sources
- **[Setup Guide](docs/data-library/SETUP.md)**

#### **Path B: Apex Fallback (Always Available)**
- Uses `KnowledgeRetrieverApex` class for SOSL queries
- Returns grounded snippets with citations
- No Data Library required
- **[Planner Instructions](docs/planner/PLANNER_INSTRUCTIONS.md)**

### **Features:**
- ✅ Dynamic schema discovery + knowledge grounding
- ✅ Citations and source attribution
- ✅ Fallback mechanisms for reliability
- ✅ Org-agnostic configuration

## � Reusable Prompt Templates

The project includes **structured prompt templates** that enable schema-aware agent behaviors:

### **Available Templates:**

#### **LeadQualification.prompt**
- **Purpose**: Intelligent lead qualification with dynamic schema discovery
- **Features**: Picklist-aware status updates, task creation, FLS compliance
- **Use Case**: Sales automation, lead scoring workflows

#### **PersonalShoppingRecommendation.prompt**
- **Purpose**: E-commerce product recommendations with inventory awareness
- **Features**: Price filtering, stock checking, knowledge-grounded suggestions
- **Use Case**: Customer service, personalized shopping assistance

### **Key Benefits:**
- 🔍 **Schema-Aware**: No hard-coded field names or SOQL
- 🛡️ **Governed**: FLS and sharing rule compliance
- 📚 **Knowledge-Integrated**: Works with Data Libraries and Knowledge articles
- 🔄 **Portable**: Adapts to different org configurations
- 📋 **Structured Output**: JSON blueprints for safe, auditable operations

**[Complete Template Guide](docs/prompt-templates/README.md)**

## �🚀 Quick Start

### Prerequisites
- **Salesforce CLI** installed (`sf`)
- **Dev Hub** access for scratch orgs
- **Developer Edition org** for full bot demos (Einstein Bots enabled)

### Development Tools

This project includes a scaffolding script to help with common development tasks:

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

# See all available commands
./scripts/scaffold.sh help
```

### Deploy Agentforce Data-Aware Agent (Lead Qualification)

```bash
# Authenticate
sf org login web --alias devhub --set-default-dev-hub

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10

# Deploy and setup
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf org open

# Test: "Qualify this lead and follow up: 00Qxxxxxxxxxxxx; set status to Working"
```

### Deploy Personal Shopping Assistant (E-commerce Bot)

```bash
# Use Developer Edition org (required for bots)
sf org login web --alias DEV_ED

# Deploy full demo with bot
sf project deploy start -x manifest/full-demo.xml -o DEV_ED
sf org open -o DEV_ED

# Access bot at: Setup > Einstein Bots > PersonalShoppingBot
# Test: "Hi, I'm looking for running shoes under $100"
```

## 📁 Project Structure

```
├── force-app/main/default/
│   ├── classes/                 # Apex classes for both projects
│   ├── genAiFunctions/          # GenAI functions
│   ├── genAiPlannerBundles/     # AI planners
│   ├── genAiPlugins/           # Metadata plugins
│   ├── bots/                   # Bot definitions
│   ├── botVersions/            # Bot versions
│   ├── objects/                # Custom objects
│   ├── permissionsets/         # Permission sets
│   ├── promptTemplates/        # AI prompts
│   └── flows/                  # Process automation
├── config/                     # Scratch org config
├── docs/                       # Documentation
├── manifest/                   # Deployment manifests
└── scripts/                    # Setup and scaffolding scripts
```

## 🔧 Key Components

### Shared Components
- **Schema Discovery**: Dynamic org metadata analysis
- **FLS Enforcement**: Field-level security compliance
- **Audit Logging**: Operation tracking and compliance

### Agentforce Data-Aware Agent
- **AutoDataAwarePlanner**: Lead qualification planner
- **Lead Management**: Status updates, task creation
- **SOQL Builder**: Safe query construction

### Personal Shopping Assistant
- **PersonalShoppingPlanner**: Shopping assistance planner
- **Inventory Management**: Dynamic stock checking
- **Product Discovery**: Catalog navigation

## 📚 Documentation

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
# Run all tests
sf apex run test --result-format human --code-coverage --wait 30

# Run specific test class
sf apex run test --tests AgentLeadActionTests --result-format human --wait 10
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

- Check documentation in `docs/` folder
- Review GitHub Actions workflow logs
- Open issues for bugs or feature requests
