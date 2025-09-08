# Trigger-Scenario-Bulkified-Optimized-

Complex Salesforce Trigger Scenario (Bulkified & Optimized)

🔥 Scenario:
 - When a Case is created/updated:
 - If Priority = High and Status = New, auto-create a Task for the Case Owner.
 - Update the related Account’s High_Priority_Cases__c count.
 - If more than 5 High Priority Open Cases exist for the same Account → auto-update the Account Health__c = "Critical".
 - Must be bulk-safe, recursion-free, and optimized.

🧑‍💻 Interview Q&A (10+ Yrs Developer Style)
Q1. How do you handle recursion here?
 👉 No recursion issue since only Tasks + Accounts are updated. If recursion risk existed, we’d use a static Set<Id> guard.

Q2. How do you ensure bulk-safety?
 👉 All SOQL & DML operations are outside loops. Using Set<Id> + AggregateResult ensures efficient queries.

Q3. Why keep trigger logic minimal?
 👉 To follow Single Responsibility Principle (SRP) — trigger only delegates, business logic stays in handler.

Q4. Why use AggregateResult?
 👉 It prevents multiple queries per Account and optimizes performance.

Q5. How would you extend this?
 👉 Easily — e.g., notify via Email/Slack if Account Health becomes Critical, just by adding one method in handler.
