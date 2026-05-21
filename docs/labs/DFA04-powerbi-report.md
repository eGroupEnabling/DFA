## DFA04: Create Power BI Report from OneLake/Fabric Data

**Objective**: Build a report from the sales semantic model created in DFA02, with
optional reference to DFA03 product-search output.

**Estimated time**: 10-15 minutes

### Steps

1. Confirm the `orders_bronze` semantic model from DFA02 exists.
    - If it already exists, continue to Step 2.
    - If it does not exist, create it from the Lakehouse table `dbo.orders_bronze`.

2. In your Fabric workspace, select **New item** → **Report**.

3. Choose the `orders_bronze` semantic model.
    - If prompted, select **Auto-create report** to generate starter visuals immediately.

4. Add these DAX measures if they are missing:
   ```dax
   Net Sales =
   SUMX(
       orders_bronze,
       orders_bronze[Quantity]
           * orders_bronze[UnitPrice]
           * (1 - (orders_bronze[DiscountPct] / 100))
   )

   Gross Margin =
   SUMX(
       orders_bronze,
       orders_bronze[Quantity]
           * (
               (orders_bronze[UnitPrice] * (1 - (orders_bronze[DiscountPct] / 100)))
               - orders_bronze[UnitCost]
           )
   )
   ```

   This one is new:
   ```dax
   Average Discount Pct = AVERAGE(orders_bronze[DiscountPct])
   ```

5. Build visuals:
   - Clustered column chart: Axis `Region`, Values `Net Sales`.
   - Line chart: Axis `OrderMonth`, Values `Net Sales`.
   - Matrix: Rows `ProductCategory`, Columns `CustomerSegment`, Values `Net
     Sales`, `Gross Margin`.
   - Slicers: `SalesChannel`, `SupportPlan`, `SalesMotion`.

6. Add one NLQ visual from **Copilot** or chat:
    - Use this prompt: `Create a visual that shows gross margin by customer
      segment and support plan.`

7. Save the report as `DFA04-Sales-Report` and publish it to the workspace.

### Success Criteria

- Report renders correctly.
- Filters and visuals respond to slicer changes.
- NLQ-generated visual is included in report canvas.
