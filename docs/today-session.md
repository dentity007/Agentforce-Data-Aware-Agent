# 📘 Data-Aware Agent: Schema Awareness, Decisions, and Demo Setup

## 1. How the Agent Knows the Schema (ERD)
The **data-aware agent** leverages Salesforce **Metadata API** and **Apex `Schema.describe*` methods** to self-discover the data model:
- **Objects**: e.g., `Contact`, `Product2`, `Order`.
- **Fields**: Including custom fields like `Inventory__c`, `StockLevel__c`, `LoyaltyTier__c`.
- **Relationships**: Lookups, master-detail, and child relationships (e.g., `Contact → Orders`).

### Mechanism
1. **`Schema.getGlobalDescribe()`** lists all available objects in the org.  
2. **`SObjectType.getDescribe()`** fetches metadata for one object (fields, labels, relationships).  
3. The agent serializes these into JSON so the planner (GenAI) can reason about them dynamically.  
4. **Data Cloud grounding** complements this with real-time profile and purchase data.

👉 This makes the agent **org-agnostic** — it adapts automatically when fields/objects differ across environments.

---

## 2. What Decisions the Agent Can Make with Schema + Data
By knowing both the ERD and live data, the agent can **make adaptive, context-sensitive decisions**.

| **Scenario**            | **Static Bot**                           | **Data-Aware Agent**                                                                 |
|--------------------------|------------------------------------------|--------------------------------------------------------------------------------------|
| **Inventory Check**      | Hard-coded to `Inventory__c` field.      | Discovers which field represents inventory (`Inventory__c`, `StockLevel__c`, etc.).   |
| **Purchase History**     | Always assumes Orders.                   | Traverses relationships dynamically (Orders, Opportunities, or custom objects).      |
| **Recommendations**      | Always shows static featured items.      | Uses Data Cloud + inventory filter → *“Recommend items in stock you’ve bought before”*. |
| **Upsell Strategy**      | Always tries an upsell.                  | Adjusts: If high `LifetimeValue__c` → premium upsell. If high `ServiceCaseCount` → service-first. |
| **Custom Fields**        | Ignores unless manually coded.           | Detects `LoyaltyTier__c` → *“Since you’re Gold Tier, you qualify for…”*.              |
| **Org Portability**      | Breaks across orgs.                      | Works anywhere — schema discovery keeps it org-agnostic.                              |

---

## 3. Demo Environment Setup
### Required Org
- **Developer Edition org** with:
  - Data Cloud enabled
  - Einstein Bots enabled
  - GenAI (Prompt Builder) features

### Steps
1. **Create scratch orgs** if you just want Apex-only testing.  
2. **Use Dev Edition** to deploy full demo including Bots and GenAI metadata.  
3. **Deploy artifacts**:
   ```bash
   # Deploy everything
   sf project deploy start -d force-app -o DEV_ED

   # Or deploy full demo (with Bot + BotVersion)
   sf project deploy start -x manifest/full-demo.xml -o DEV_ED
   ```
4. **Test Bot**:
   - Go to Setup → Einstein Bots → activate `PersonalShoppingBot`.
   - Chat: *“Show me products in stock under $50”* → agent dynamically discovers inventory field + filters.

---

## 4. Export/Import Workflow (Definitions Only)
We proved export/import works with Apex classes:
1. Export:
   ```bash
   sf project retrieve start -x manifest/genai-only.xml -o psa-src -r out/genai-only
   ```
   → produces `out/genai-only.zip`.
2. Import:
   ```bash
   sf metadata deploy -o psa-tgt -f out/genai-only.zip -w 30 --test-level NoTestRun
   ```

This validated the **metadata transport pipeline** (export → zip → import).  
⚠️ Only Apex classes retrieved cleanly — GenAI metadata is not yet supported in scratch orgs.

---

## 5. Key Takeaways
- **Schema Awareness**: Agents dynamically discover ERD → resilient across orgs.  
- **Decision Making**: Can adapt recommendations, upsells, and queries based on schema + Data Cloud data.  
- **Test Orgs**: Scratch orgs limited to Apex. Use **Dev Edition with Bots + Prompt Builder** for full demo.  
- **Export/Import**: Works for Apex; pipeline proven for definitions → ready for Bots/GenAI once available in your org.  

---

👉 Next Steps:
- Run full demo in Dev Edition org with `personal-shopping-assistant-sfdx-bot.zip`.  
- Add a **sample conversation script** to validate end-to-end flow.  
