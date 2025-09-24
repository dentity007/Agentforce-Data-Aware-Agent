# Prompt Templates for Data-Aware Agents

This directory contains reusable prompt templates that enable schema-aware, knowledge-grounded agent behaviors in Salesforce Agentforce.

## Overview

Prompt templates provide structured, reusable instructions for AI agents that:
- **Discover schema dynamically** instead of using hard-coded field names
- **Generate governed queries** through blueprint structures
- **Integrate knowledge grounding** from Data Libraries or Knowledge articles
- **Maintain portability** across different Salesforce org configurations

## Available Templates

### 1. LeadQualification.prompt

**Purpose**: Intelligent lead qualification and follow-up automation

**Key Features**:
- Dynamic schema discovery for Lead object fields
- Picklist-aware status updates
- Task creation for follow-up activities
- FLS-compliant field operations

**Use Cases**:
- Sales lead scoring and qualification
- Automated lead routing
- Follow-up task creation

**Inputs Required**:
- `user_instruction`: Natural language qualification request
- `schema_json`: Discovered org schema
- `lead_record_json`: Current lead data (optional)
- `allowed_status_values_json`: Valid status picklist values (optional)

**Output Format**:
```json
{
  "update_blueprint": {
    "sobject": "Lead",
    "id": "<lead_id>",
    "fields": {
      "Status": "Qualified",
      "Rating": "Hot"
    }
  },
  "task_blueprint": {
    "sobject": "Task",
    "fields": {
      "WhoId": "<lead_id>",
      "Subject": "Follow up on qualified lead",
      "ActivityDate": "<followup_date>"
    }
  },
  "followups": ["Questions for clarification"],
  "rationale": "Schema discovery explanation"
}
```

### 2. PersonalShoppingRecommendation.prompt

**Purpose**: E-commerce product recommendations with inventory awareness

**Key Features**:
- Dynamic product catalog discovery
- Price range filtering
- Inventory availability checking
- Knowledge-grounded recommendations
- Relationship-aware queries

**Use Cases**:
- Personalized product suggestions
- Inventory-aware shopping assistance
- Price comparison and recommendations
- Customer service automation

**Inputs Required**:
- `user_query`: Customer shopping request
- `schema_json`: Discovered org schema
- `data_cloud_context`: Knowledge base context (optional)
- `inventory_context`: Current stock data (optional)
- `price_range`: Budget constraints (optional)
- `candidate_products_json`: Pre-filtered suggestions (optional)

**Output Format**:
```json
{
  "soql_blueprints": [{
    "rootObject": "Product2",
    "fields": ["Id", "Name", "Price", "Inventory"],
    "filters": [
      {"fieldRef": "Inventory", "op": ">", "valueRef": "0"},
      {"fieldRef": "Price", "op": "<=", "valueRef": "100"}
    ],
    "orderBy": [{"fieldRef": "Price", "direction": "ASC"}],
    "limit": 10
  }],
  "chosen_fields": {
    "Product2": ["Id", "Name", "Price", "Inventory"]
  },
  "followups": ["Preference questions"],
  "rationale": "Recommendation logic explanation"
}
```

## Integration Guide

### Wiring Templates into Agentforce Planners

1. **Create Planner Bundle**:
   ```xml
   <GenAiPlannerBundle>
     <promptTemplate>LeadQualification</promptTemplate>
     <actions>
       <fullName>FindObjects</fullName>
       <fullName>FindFields</fullName>
       <fullName>ExecuteSOQL</fullName>
     </actions>
   </GenAiPlannerBundle>
   ```

2. **Configure Input Mapping**:
   - Map schema discovery results to `schema_json`
   - Map user queries to appropriate input variables
   - Include knowledge context when available

3. **Blueprint Processing**:
   - Parse JSON output from template
   - Execute `soql_blueprints` through ExecuteSOQL action
   - Apply `update_blueprints` through UpdateLeadStatusAction
   - Create tasks from `task_blueprints`

### Schema Discovery Integration

Templates expect schema information in this format:
```json
{
  "Lead": {
    "fields": {
      "Status": {"type": "picklist", "values": ["Open", "Qualified", "Unqualified"]},
      "Rating": {"type": "picklist", "values": ["Hot", "Warm", "Cold"]}
    }
  }
}
```

Use `FindObjects` and `FindFields` actions to populate this context.

### Knowledge Grounding

Templates integrate with knowledge through:
- **Data Library**: Automatic grounding via "Answer Questions with Knowledge" action
- **Apex Fallback**: `KnowledgeRetrieverApex` for SOSL-based retrieval
- **Context Injection**: Knowledge snippets provided as `data_cloud_context`

## Best Practices

### Schema-Aware Development
- Always use discovered field names over hard-coded values
- Validate picklist values dynamically
- Respect FLS and sharing rules
- Test across different org configurations

### Blueprint Structure
- Use `soql_blueprints` for read operations
- Use `update_blueprints` for write operations
- Include `task_blueprints` for follow-up automation
- Provide clear `rationale` for auditability

### Error Handling
- Include `followups` for missing information
- Validate blueprint structure before execution
- Handle schema discovery failures gracefully
- Provide fallback behaviors for missing context

## Testing and Validation

### Unit Testing
```apex
@IsTest
static void testLeadQualificationTemplate() {
    // Test with mock schema and inputs
    // Validate blueprint structure
    // Verify field discovery usage
}
```

### Integration Testing
- Deploy to scratch org with varied schema
- Test with different knowledge configurations
- Validate FLS compliance
- Performance test with large catalogs

## Troubleshooting

### Common Issues

**"Field not found" errors**:
- Ensure schema discovery runs before template execution
- Check FLS permissions on discovered fields
- Validate field API names in blueprint

**Empty recommendations**:
- Verify inventory context is populated
- Check price range filtering logic
- Validate product catalog accessibility

**Knowledge not grounding**:
- Confirm Data Library configuration
- Check KnowledgeRetrieverApex deployment
- Validate knowledge article publishing

## Security Considerations

- All field access validated through FLS checks
- Blueprint execution audited for compliance
- Knowledge retrieval respects sharing rules
- No direct SOQL execution in templates

## Performance Optimization

- Cache schema discovery results
- Limit blueprint complexity
- Use efficient filtering in SOQL blueprints
- Batch operations where possible

## Related Documentation

- [Data Library Setup](../data-library/SETUP.md)
- [Planner Instructions](../planner/PLANNER_INSTRUCTIONS.md)
- [Knowledge Integration Guide](../KNOWLEDGE_INTEGRATION_GUIDE.md)
