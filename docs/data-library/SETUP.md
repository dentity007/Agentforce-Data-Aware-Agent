# Agentforce Data Library (Knowledge/RAG) — Setup

Use a Data Library to ground answers with trusted sources (Knowledge/articles, files, web). The built-in **Answer Questions with Knowledge** action uses the library you assign.

## Prereqs
- Data Cloud and Agentforce enabled.
- This repo’s agent template (planner + actions) already deployed.

## Steps (Sandbox first)
1. **Create a Data Library**
   - Go to **Setup → Agentforce Data Library → New Library**.
   - Start with **Salesforce Knowledge**. (You can add other sources later.)
   - Save and let indexing complete.

2. **Attach the Library to your Agent**
   - Open your agent in **Agentforce Builder**.
   - **Add Action → Answer Questions with Knowledge**.
   - Select the Data Library you just created.
   - (Optional) Enable **Show sources** so the agent can cite them.

3. **Test the grounding**
   - In Builder, ask: “What’s our return policy?”
   - You should see answers grounded in articles, with citations.
