# Knowledge-Grounded Agent Integration Guide

This guide explains how the unified agentforce project integrates knowledge-grounded capabilities using Salesforce Knowledge for enhanced RAG (Retrieval-Augmented Generation) responses.

## 🏗️ Architecture Overview

The knowledge-grounded capabilities are implemented through a dual-path approach:

### Path A: Agentforce Data Library (Production Recommended)
```
User Query → Agent → Data Library → Knowledge Articles → Grounded Response
```

### Path B: Apex Fallback (Always Available)
```
User Query → Agent → KnowledgeRetrieverApex → SOSL Query → Knowledge Articles → Grounded Response
```

## 🔧 Implementation Details

### KnowledgeRetrieverApex Class

**Purpose**: Fallback knowledge retrieval when Data Library isn't configured.

**Key Features**:
- SOSL queries against `KnowledgeArticleVersion` object
- Returns ranked snippets with citations
- Lightweight and org-agnostic
- Read-only operations with proper error handling

**Method Signature**:
```apex
@InvocableMethod(label='Retrieve Knowledge Snippets')
public static List<Output> run(List<Input> inputs)
```

**Input Parameters**:
- `question`: Natural language question to search for
- `maxResults`: Maximum results (1-10, default 3)

**Output**:
- `context`: Plaintext snippets for RAG context
- `citationsJson`: Structured citation data

### GenAI Function Integration

**Function Name**: `RetrieveKnowledgeSnippets`
- **Apex Class**: `KnowledgeRetrieverApex`
- **Inputs**: `question`, `maxResults`
- **Outputs**: `context`, `citationsJson`

### Planner Integration

Both planners (`AutoDataAwarePlanner` and `PersonalShoppingPlanner`) now include:

1. **Knowledge Retrieval Step**: Call `RetrieveKnowledgeSnippets` early in reasoning
2. **Citation Integration**: Include knowledge sources in responses
3. **Fallback Logic**: Graceful degradation when knowledge isn't available

## 📋 Setup Instructions

### Option 1: Data Library Setup (Recommended)

1. **Navigate to Setup** → **Agentforce Data Library** → **New Library**
2. **Select Sources**: Choose Salesforce Knowledge as primary source
3. **Configure Agent**:
   - Open agent in Agentforce Builder
   - Add **"Answer Questions with Knowledge"** action
   - Select your Data Library
   - Enable **"Show sources"** for citations

4. **Test**: Ask "What is our return policy?"

### Option 2: Apex Fallback Setup

1. **Deploy Classes**:
   ```bash
   sf project deploy start --manifest manifest/package.xml --wait 30
   ```

2. **Configure Agent**:
   - In Agentforce Builder → Add Action → Apex
   - Select `KnowledgeRetrieverApex.run`
   - Add guidance: "Retrieve knowledge snippets before answering"

3. **Update Planner**: Use instructions from `docs/planner/PLANNER_INSTRUCTIONS.md`

## 🔄 Integration Workflow

### For Lead Qualification Agent:
1. User asks: *"What are the requirements for lead qualification?"*
2. Agent calls `RetrieveKnowledgeSnippets` with question
3. Receives policy snippets from Knowledge articles
4. Discovers lead schema using metadata functions
5. Combines knowledge + data for comprehensive response

### For Shopping Assistant:
1. User asks: *"Do you offer free shipping?"*
2. Agent retrieves shipping policy from Knowledge
3. Checks inventory using dynamic field discovery
4. Provides grounded recommendations with citations

## 📊 Benefits

### Enhanced Accuracy
- Responses grounded in authoritative knowledge sources
- Reduced hallucinations through RAG implementation
- Consistent answers across agent interactions

### Org Portability
- Works across different Salesforce orgs
- No hard-coded knowledge assumptions
- Dynamic adaptation to available content

### Compliance & Governance
- Citations provide audit trails
- FLS and sharing rules respected
- Knowledge access follows org permissions

## 🧪 Testing Strategy

### Unit Tests
- `KnowledgeRetrieverApex_Test`: Validates SOSL queries and output formatting
- Tests edge cases: empty results, malformed queries, permission issues

### Integration Tests
- End-to-end agent conversations with knowledge retrieval
- Citation accuracy validation
- Performance testing with various knowledge base sizes

### Manual Testing Scenarios
1. **Policy Questions**: "What is our refund policy?"
2. **FAQ Queries**: "How do I track my order?"
3. **Complex Scenarios**: Combine knowledge + data queries

## 🚀 Deployment Checklist

- [ ] Deploy `KnowledgeRetrieverApex` and test classes
- [ ] Update planner bundles with knowledge instructions
- [ ] Configure Data Library (or verify Apex fallback)
- [ ] Test agent conversations with knowledge retrieval
- [ ] Validate citations and source attribution
- [ ] Document knowledge sources for maintenance

## 🔍 Troubleshooting

### Common Issues

**No Knowledge Results**:
- Check Knowledge articles are published and searchable
- Verify SOSL query syntax
- Confirm user has access to Knowledge objects

**Citation Errors**:
- Validate JSON structure in `citationsJson`
- Check for special characters in article titles
- Ensure article IDs are valid

**Performance Issues**:
- Limit `maxResults` to 3-5 for optimal performance
- Consider caching frequently accessed knowledge
- Monitor SOSL query limits

### Debug Steps

1. **Test Apex Directly**:
   ```apex
   KnowledgeRetrieverApex.Input input = new KnowledgeRetrieverApex.Input();
   input.question = 'test question';
   input.maxResults = 3;
   List<KnowledgeRetrieverApex.Output> results = KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{input});
   System.debug(results);
   ```

2. **Check Knowledge Data**:
   - Query `KnowledgeArticleVersion` for test articles
   - Verify articles are published and searchable

3. **Validate Permissions**:
   - Ensure user can access Knowledge objects
   - Check FLS on Knowledge fields

## 📈 Future Enhancements

- **Multi-source Integration**: Combine Knowledge with external APIs
- **Semantic Caching**: Cache frequent knowledge queries
- **Advanced Ranking**: ML-based result ranking
- **Knowledge Health Monitoring**: Automated quality checks

## 📚 Related Documentation

- [Data Library Setup](docs/data-library/SETUP.md)
- [Planner Instructions](docs/planner/PLANNER_INSTRUCTIONS.md)
- [Agentforce Data-Aware Agent](docs/Team_Playbook.md)
- [Personal Shopping Assistant](docs/conversation-demo.md)</content>
<parameter name="filePath">/Users/nmaine/Downloads/agentforce-data-aware/docs/KNOWLEDGE_INTEGRATION_GUIDE.md