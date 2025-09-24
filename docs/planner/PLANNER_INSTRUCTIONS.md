# Planner / Topic Instruction Snippets (Copy-Paste)

Use these snippets in your **Schema Explorer / Context** step and main policy to make the agent knowledge-grounded and schema-aware.

## High-level policy (add to your planner bundle narrative/instructions)
- Before drafting an answer or composing recommendations:
  1. **Discover schema**: Call your metadata discovery action to enumerate relevant objects, fields, and relationships in the current org. Prefer dynamic traversal over hard-coded SOQL.
  2. **Ground with knowledge**:
     - **If the built-in “Answer Questions with Knowledge” action is available and a Data Library is assigned**: call it with the user’s question to retrieve authoritative passages and sources.
     - **Else**: call the custom Apex action **Retrieve Knowledge Snippets** with the user’s question. Use the returned `context` and cite items from `citationsJson`.

- When forming queries:
  - Avoid hard-coding field names; prefer discovered fields/relationships.
  - Only query for fields necessary to fulfill the user’s request.
  - Explain assumptions and include citations for any knowledge-based statements.
