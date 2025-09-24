# Unified Agentforce Data-Aware Solutions

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

## 🚀 Quick Start

### Prerequisites
- **Salesforce CLI** installed (`sf`)
- **Dev Hub** access for scratch orgs
- **Developer Edition org** for full bot demos (Einstein Bots enabled)

### Deploy Agentforce Data-Aware Agent (Lead Qualification)

```bash
# Authenticate
sf org login web --alias devhub --set-default-dev-hub

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias agent-data-aware --set-default --duration-days 7 --wait 10

# Deploy and setup
sf project deploy start --ignore-conflicts --wait 30
sf org assign permset --name GenAIAgentPermission
sf apex run --file scripts/apex/run_bootstrap.apex
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
└── scripts/                    # Setup scripts
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
