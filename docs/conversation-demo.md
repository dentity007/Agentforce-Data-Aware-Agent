# 🗣️ Sample Conversation Demo — Personal Shopping Assistant Bot

This script simulates a test flow with the deployed `PersonalShoppingBot` in a Dev Edition org.

---

## Step 1 — Greeting
**User:** Hi, I’m looking for new running shoes.  
**Bot:** Welcome back! Let me check our product catalog for items that match your preferences.

---

## Step 2 — Metadata-Aware Query
*(Bot dynamically discovers which inventory field exists on Product2, e.g., `StockLevel__c`)*  
**Bot (thinking):** Found field `StockLevel__c`. I’ll filter for products where `StockLevel__c > 0`.

**Bot:** I found 12 running shoes in stock right now. Do you have a price range in mind?

---

## Step 3 — Personalized Recommendation
**User:** Under $100.  
*(Bot queries Product2 and Data Cloud purchase history for this Contact)*  
**Bot:** Based on your past purchases, I recommend the **TrailRunner 3000** at $89. It’s in stock (12 available).  

Would you like me to add it to your cart?

---

## Step 4 — Upsell Logic
**User:** Sure.  
*(Bot checks customer profile in Data Cloud: `LoyaltyTier__c = Gold`)*  
**Bot:** Great! Since you’re a **Gold Tier** member, you also qualify for 20% off matching socks. Add those too?

---

## Step 5 — Completion
**User:** Yes, please.  
**Bot:** Done ✅ I’ve added the TrailRunner 3000 and socks bundle to your cart.  

Anything else I can help with today?

---

## Notes for Demo
- **Inventory field** is dynamically detected — demo works even if org has a custom field.  
- **Purchase history** and **loyalty tier** are pulled from **Data Cloud**.  
- **Upsell** logic shows the agent’s ability to make schema + data-driven decisions.  

👉 Use this script as a **walkthrough** when showing the bot to stakeholders.
