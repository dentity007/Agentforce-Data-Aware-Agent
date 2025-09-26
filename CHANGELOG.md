# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- **Automated Release Management**: Implemented semantic versioning with GitHub Actions
  - Conventional commits trigger automatic version bumps
  - Automated changelog generation and GitHub releases
  - Release-please integration for streamlined release process

### Changed
- **Release Badge**: Updated README to use dynamic release badge from GitHub releases
- **Documentation**: Added automated releases section explaining semantic versioning process

## [0.3.0] - 2025-09-25

### Fixed
- **InvocableActionFactory.cls**: Fixed malformed code with missing return statements, unbalanced braces, and variable naming conflicts (renamed `desc` to `body`)
- **InventoryReserveTests.cls**: Updated test to create real Account records for Task insertion validation, ensuring WhatId references valid records
- **Package Manifest**: Added missing `InventoryReserveTests` to `manifest/package.xml` for complete deployment coverage

### Added
- **Checkpoint Guard System**: Input validation before database operations
  - `ActionOrchestrator` now validates required/optional fields and numeric values before DML
  - Blocks execution with clear error messages for missing or invalid inputs
  - Prevents database operations until all guardrails pass
- **Enhanced Guardrails**: Support for `optionalFields` and `numericFields` in action definitions
  - `InventoryReserve` marks `AccountId` as optional and `Quantity` as numeric (> 0)
  - Extensible framework for future validation rules
- **OrchestratorCheckpointGuardTests.cls**: Comprehensive test coverage (3 tests, 100% pass rate)
  - Tests missing required fields, invalid numeric values, and valid inputs
  - Validates guard blocks database operations appropriately

### Changed
- **Inventory Reserve Action**: Improved error handling and input validation in the DOMAIN action for better reliability
- **Task Creation**: Enhanced Task description formatting for inventory reservations with proper field inclusion

### Technical Details
- All Apex classes now compile without errors
- Test execution passes with 100% success rate
- Deployment validated in Salesforce scratch org
- Source tracking and git history maintained

## [0.2.0] - 2025-09-XX

### Added
- Initial implementation of Agentforce Data-Aware Agent
- Schema discovery and slicing capabilities
- PII redaction and privacy protection
- Dynamic action generation and orchestration
- Knowledge-grounded responses integration
- Comprehensive test suite with 35+ Apex classes

### Features
- Lead qualification automation
- Personal shopping assistant
- Inventory checking and loan eligibility demos
- Prompt templates for schema-aware behaviors
- FLS and sharing rule compliance

## [0.1.0] - 2025-08-XX

### Added
- Project initialization
- Basic Salesforce DX structure
- Core architecture documentation
- Initial deployment scripts</content>
<parameter name="filePath">/Users/nmaine/Downloads/agentforce-data-aware/CHANGELOG.md