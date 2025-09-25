#!/bin/bash

# scaffold.sh - Salesforce DX Agentforce Project Scaffolding Script
#
# This script provides common scaffolding operations for the Agentforce Data-Aware project.
# It helps with creating new components, setting up environments, and managing deployments.
#
# Usage: ./scaffold.sh [command] [options]
#
# Commands:
#   help          Show this help message
#   setup         Initial project setup and validation
#   create        Create new Salesforce components
#   deploy        Deploy to scratch org
#   test          Run tests
#   clean         Clean up temporary files
#
# Examples:
#   ./scaffold.sh setup dev
#   ./scaffold.sh create class MyNewClass
#   ./scaffold.sh deploy
#   ./scaffold.sh test

set -euo pipefail

# Configuration
PROJECT_NAME="agentforce-data-aware"
DEFAULT_ORG_ALIAS="agent-data-aware"
DEFAULT_DURATION="7"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Salesforce CLI is installed
check_cli() {
    if ! command -v sf &> /dev/null; then
        log_error "Salesforce CLI (sf) is not installed. Please install it first."
        log_info "Visit: https://developer.salesforce.com/tools/sfdxcli"
        exit 1
    fi
}

# Validate project structure
validate_project() {
    log_info "Validating project structure..."

    required_files=(
        "sfdx-project.json"
        "force-app/main/default/classes/"
        "manifest/package.xml"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            log_error "Required file/directory missing: $file"
            return 1
        fi
    done

    log_success "Project structure is valid"
    return 0
}

# Setup command
cmd_setup() {
    local env_type="${1:-dev}"

    log_info "Setting up $env_type environment..."

    check_cli
    validate_project

    case "$env_type" in
        "dev")
            setup_dev_environment
            ;;
        "test")
            setup_test_environment
            ;;
        "prod")
            log_warning "Production setup should be done manually for safety"
            exit 1
            ;;
        *)
            log_error "Unknown environment type: $env_type"
            log_info "Available types: dev, test"
            exit 1
            ;;
    esac
}

# Setup development environment
setup_dev_environment() {
    log_info "Creating scratch org..."

    # Create scratch org
    sf org create scratch \
        --definition-file config/project-scratch-def.json \
        --alias "$DEFAULT_ORG_ALIAS" \
        --set-default \
        --duration-days "$DEFAULT_DURATION" \
        --wait 10

    log_success "Scratch org created: $DEFAULT_ORG_ALIAS"

    # Deploy source
    log_info "Deploying source code..."
    sf project deploy start --ignore-conflicts --wait 30

    # Assign permissions
    log_info "Assigning permissions..."
    sf org assign permset --name GenAIAgentPermission

    # Open org
    log_info "Opening org in browser..."
    sf org open

    log_success "Development environment ready!"
    log_info "Org alias: $DEFAULT_ORG_ALIAS"
    log_info "Duration: $DEFAULT_DURATION days"
}

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."

    # Create test scratch org
    sf org create scratch \
        --definition-file config/project-scratch-def.json \
        --alias "${DEFAULT_ORG_ALIAS}-test" \
        --duration-days 1 \
        --wait 10

    log_success "Test environment created"
}

# Create component command
cmd_create() {
    local component_type="$1"
    local component_name="$2"

    if [[ -z "$component_type" || -z "$component_name" ]]; then
        log_error "Usage: $0 create <type> <name>"
        log_info "Types: class, trigger, component, aura, lwc"
        exit 1
    fi

    check_cli

    case "$component_type" in
        "class")
            create_apex_class "$component_name"
            ;;
        "trigger")
            create_apex_trigger "$component_name"
            ;;
        "lwc")
            create_lwc "$component_name"
            ;;
        "aura")
            create_aura_component "$component_name"
            ;;
        *)
            log_error "Unknown component type: $component_type"
            log_info "Supported types: class, trigger, lwc, aura"
            exit 1
            ;;
    esac
}

# Create Apex class
create_apex_class() {
    local class_name="$1"

    log_info "Creating Apex class: $class_name"

    # Create class file
    local class_file="force-app/main/default/classes/${class_name}.cls"
    local meta_file="${class_file}-meta.xml"

    cat > "$class_file" << EOF
/**
 * ${class_name} - Custom Apex class
 *
 * @author $(whoami)
 * @date $(date)
 * @group Custom Classes
 * @description TODO: Add description
 */
public with sharing class ${class_name} {

    /**
     * Default constructor
     */
    public ${class_name}() {
        // TODO: Initialize class
    }

    /**
     * Sample method - replace with actual implementation
     * @return String
     */
    public String getDescription() {
        return '${class_name} implementation';
    }
}
EOF

    # Create meta file
    cat > "$meta_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <status>Active</status>
</ApexClass>
EOF

    log_success "Created Apex class: $class_name"
    log_info "Files created:"
    log_info "  - $class_file"
    log_info "  - $meta_file"
}

# Create Apex trigger
create_apex_trigger() {
    local trigger_name="$1"
    local object_name="${2:-Account}" # Default to Account if not specified

    log_info "Creating Apex trigger: ${trigger_name} on ${object_name}"

    local trigger_file="force-app/main/default/triggers/${trigger_name}.trigger"
    local meta_file="${trigger_file}-meta.xml"

    # Create directories if they don't exist
    mkdir -p "force-app/main/default/triggers"

    cat > "$trigger_file" << EOF
/**
 * ${trigger_name} - Trigger on ${object_name}
 *
 * @author $(whoami)
 * @date $(date)
 * @group Triggers
 * @description TODO: Add trigger description
 */
trigger ${trigger_name} on ${object_name} (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    // TODO: Implement trigger logic
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Before insert logic
        } else if (Trigger.isUpdate) {
            // Before update logic
        } else if (Trigger.isDelete) {
            // Before delete logic
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // After insert logic
        } else if (Trigger.isUpdate) {
            // After update logic
        } else if (Trigger.isDelete) {
            // After delete logic
        } else if (Trigger.isUndelete) {
            // After undelete logic
        }
    }
}
EOF

    # Create meta file
    cat > "$meta_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <status>Active</status>
</ApexTrigger>
EOF

    log_success "Created Apex trigger: ${trigger_name}"
}

# Create Lightning Web Component
create_lwc() {
    local component_name="$1"

    log_info "Creating Lightning Web Component: $component_name"

    local component_dir="force-app/main/default/lwc/${component_name}"
    mkdir -p "$component_dir"

    # Create component files
    cat > "${component_dir}/${component_name}.js" << EOF
import { LightningElement } from 'lwc';

/**
 * ${component_name} - Lightning Web Component
 *
 * @author $(whoami)
 * @date $(date)
 */
export default class ${component_name} extends LightningElement {

    // Component properties
    message = 'Hello from ${component_name}!';

    // Lifecycle hooks
    connectedCallback() {
        // Component initialization logic
    }

    // Event handlers
    handleClick() {
        // Handle button click or other events
        this.message = 'Button clicked!';
    }
}
EOF

    cat > "${component_dir}/${component_name}.html" << EOF
<template>
    <div class="${component_name}">
        <h1>{message}</h1>
        <lightning-button
            label="Click Me"
            onclick={handleClick}>
        </lightning-button>
    </div>
</template>
EOF

    cat > "${component_dir}/${component_name}.js-meta.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>
EOF

    log_success "Created Lightning Web Component: $component_name"
}

# Create Aura component
create_aura_component() {
    local component_name="$1"

    log_info "Creating Aura Component: $component_name"

    local component_dir="force-app/main/default/aura/${component_name}"
    mkdir -p "$component_dir"

    # Create component files
    cat > "${component_dir}/${component_name}.cmp" << EOF
<aura:component implements="flexipage:availableForAllPageTypes" access="global">
    <aura:attribute name="message" type="String" default="Hello from ${component_name}!"/>

    <div class="${component_name}">
        <h1>{!v.message}</h1>
        <lightning:button label="Click Me" onclick="{!c.handleClick}"/>
    </div>
</aura:component>
EOF

    cat > "${component_dir}/${component_name}Controller.js" << EOF
({
    handleClick: function(component, event, helper) {
        // Handle button click
        component.set("v.message", "Button clicked!");
    }
})
EOF

    cat > "${component_dir}/${component_name}.css" << EOF
.THIS.${component_name} {
    padding: 1rem;
    text-align: center;
}

.THIS h1 {
    color: #0070d2;
}
EOF

    log_success "Created Aura Component: $component_name"
}

# Deploy command
cmd_deploy() {
    check_cli

    log_info "Deploying to default org..."

    # Validate before deploy
    validate_project

    # Deploy source
    sf project deploy start --ignore-conflicts --wait 30

    # Assign permissions if needed
    if sf org list | grep -q "GenAIAgentPermission"; then
        log_info "Assigning permissions..."
        sf org assign permset --name GenAIAgentPermission
    fi

    log_success "Deployment completed!"
}

# Test command
cmd_test() {
    check_cli

    log_info "Running tests..."

    # Run all tests
    sf apex run test \
        --result-format human \
        --code-coverage \
        --wait 30 \
        --verbose

    log_success "Tests completed!"
}

# Clean command
cmd_clean() {
    log_info "Cleaning up temporary files..."

    # Remove common temporary files
    find . -name "*.log" -type f -delete
    find . -name "*.tmp" -type f -delete
    find . -name ".DS_Store" -type f -delete
    find . -name "npm-debug.log*" -type f -delete

    # Clean SFDX cache
    rm -rf .sfdx/
    rm -rf .sf/

    log_success "Cleanup completed!"
}

# Help command
cmd_help() {
    cat << EOF
scaffold.sh - Salesforce DX Agentforce Project Scaffolding Script

USAGE:
    ./scaffold.sh [command] [options]

COMMANDS:
    help                    Show this help message
    setup [env]             Setup environment (dev, test)
    create <type> <name>    Create new Salesforce component
    deploy                  Deploy to default org
    test                    Run all tests
    clean                   Clean temporary files

CREATE TYPES:
    class <name>            Create Apex class
    trigger <name> [object] Create Apex trigger (default object: Account)
    lwc <name>              Create Lightning Web Component
    aura <name>             Create Aura component

EXAMPLES:
    ./scaffold.sh setup dev
    ./scaffold.sh create class MyCustomClass
    ./scaffold.sh create trigger MyTrigger Account
    ./scaffold.sh create lwc myComponent
    ./scaffold.sh deploy
    ./scaffold.sh test

ENVIRONMENT VARIABLES:
    SF_ORG_ALIAS            Override default org alias
    SF_DURATION             Override scratch org duration (days)

For more information, see the project README.md
EOF
}

# Main script logic
main() {
    local command="${1:-help}"

    case "$command" in
        "help"|"-h"|"--help")
            cmd_help
            ;;
        "setup")
            shift
            cmd_setup "$@"
            ;;
        "create")
            shift
            cmd_create "$@"
            ;;
        "deploy")
            cmd_deploy
            ;;
        "test")
            cmd_test
            ;;
        "clean")
            cmd_clean
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            cmd_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"