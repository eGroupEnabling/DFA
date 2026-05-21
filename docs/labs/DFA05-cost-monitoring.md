## DFA05: Monitor Costs

**Objective**: Review charges, identify top cost drivers, check Fabric capacity
health, and configure budget alerts.

**Estimated time**: 10-15 minutes

### Steps

1. Review Fabric monitoring and capacity health:
   - In Fabric, open **Monitoring hub** to review recent refreshes, notebook
     runs, or pipeline activity.
   - If you have access, open the
     [Microsoft Fabric Capacity Metrics app](https://learn.microsoft.com/en-us/fabric/enterprise/metrics-app-install)
     and review CU usage, interactive versus background operations, and any
     throttling or overload.
   - Use this view to determine whether capacity pressure is contributing to
     slowdowns or refresh issues.

2. In the Azure portal:
   - Go to **Cost Management** → **Cost Analysis** under *Reporting + analytics*.
   - Set the scope to the subscription or resource group used for this
     accelerator.
   - Select **Daily costs** to review per-day spend across resources.

3. Analyze by service:
   - Group by **Service name**.
   - Confirm the largest contributors, which typically include SQL, storage,
     and Fabric-related services.

4. Review the expected cost pattern:
   - **Fabric Capacity**: $0 during trial, or pay-as-you-go based on
     [Microsoft Fabric pricing](https://azure.microsoft.com/en-us/pricing/details/microsoft-fabric/).
   - **Data Lake Storage**: typically low and driven by data volume.
   - **SQL Database (Basic)**: steady baseline cost.
   - **Function App**: usually low unless heavily used.
   - **Key Vault**: usually minimal unless transaction volume is high.

5. Create budget alerts:
   - Go to **Cost Management** → **Budgets** under *Monitoring* and select
     **Add**.
   - Create a monthly budget at the same scope you reviewed in Cost Analysis.
   - Add **actual cost** thresholds such as 50%, 90%, and 100%.
   - Add a **forecasted cost** threshold if you want an earlier warning when
     projected month-end spend is expected to exceed the budget.
   - Use both condition types when possible: **actual cost** alerts fire after
     spend is incurred, while **forecasted cost** alerts help you react before
     the budget is exceeded.

### Success Criteria

- You can identify your top cost services.
- You reviewed Fabric monitoring and, if available, checked capacity health.
- You have budget alerts configured.
