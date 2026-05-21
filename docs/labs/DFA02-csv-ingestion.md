## DFA02: Load CSV from Azure Storage into OneLake

**Objective**: Load a richer sales CSV from Azure Data Lake Storage Gen2
(ADLS Gen2) into OneLake, then expose it through a semantic model for
Copilot-assisted exploration.

**Assets used**:

- `samples/labs/DFA02-orders.csv`

**Estimated time**: 30-40 minutes

### Steps

1. Upload `samples/labs/DFA02-orders.csv` to the `raw` container in your
    deployed storage account.
    The deployment creates this storage account as ADLS Gen2 and provisions the
    `raw` container for landing files.
    This file contains about 1,000 orders with customer, geography, product,
    support, contract, and sales-lifecycle attributes.

2. In a Fabric workspace, select **New item**, then create a new **Lakehouse**
   named `DFA02`.

3. Add a OneLake shortcut to ADLS:
   - In the **Lakehouse**, select **New shortcut** under **Get data in your
     lakehouse**.
   - Choose your ADLS Gen2 account and the `raw` container.
   - If you need to create a new connection to Azure, use the container URL
     from the storage account.
   - The storage account deployed by this accelerator already has
     Hierarchical Namespace enabled and blob and container soft delete
     disabled.
   - If the URL contains `blob.core`, replace `blob` with `dfs`.
   - If you are using a different storage account and receive a 409 error
     mentioning `BlobStorageEvents` or `SoftDelete`, disable those features on
     that account before retrying.
   - For **Authentication kind**, choose **Account Key** and use one of the
     storage account access keys.
   - Select the `raw` container, confirm that `DFA02-orders.csv` is visible,
     then select **Next**, **Next**, and **Create**.
   - If you receive `Target path doesn't exist`, verify that Hierarchical
     Namespace is enabled on the storage account you selected.

4. Load the CSV with Dataflow Gen2:
   - Create a **Dataflow Gen2** under **Get data in your lakehouse**.
   - Open the **Get data** dialog from the ribbon or from the middle of the
     page.
   - In the **Choose data source** window, select **Azure Data Lake Storage
     Gen2**.
   - Connect to the same storage account, then select **Create**.
   - In the query results, select `[Binary]` in the **Content** column for
     `DFA02-orders.csv`.
   - Let Power Query create the navigation steps until the preview shows the
     CSV row data.
   - In **Data destination** settings, choose the `DFA02` Lakehouse and set
     the table name to `orders_bronze`.
   - Leave column mapping on **Automatic settings**, then select
     **Save settings**.
   - Select **Save and run**. The initial run can take up to a minute.
   - Optional: After the first run completes, open **Recent runs**. To enable
     scheduled refresh, select **Schedule refresh**, then select
     **+ Add schedule** and choose an interval such as every 15 minutes. Close
     the schedule window and the Dataflow to save your changes.

5. Validate ingestion in the **SQL analytics endpoint**. Use the
   **Analyze data with** dropdown at the top left of the `DFA02` Lakehouse:
   ```sql
   SELECT
       COUNT(*) AS TotalRowCount,
       COUNT(DISTINCT CustomerName) AS CustomerCount,
       COUNT(DISTINCT ProductName) AS ProductCount
   FROM dbo.orders_bronze;

   SELECT TOP 10
       OrderDate,
       CustomerName,
       CustomerSegment,
       ProductCategory,
       SalesChannel,
       SalesMotion,
       Quantity,
       UnitPrice,
       DiscountPct,
       Quantity * UnitPrice * (1 - (DiscountPct / 100.0)) AS NetSales
   FROM dbo.orders_bronze
   ORDER BY OrderDate DESC, OrderID DESC;
   ```

6. Create a semantic model:
   - Open the `DFA02` **Lakehouse** or **SQL analytics endpoint**.
   - Select **New semantic model** from that item.
   - Enter `sm_orders` as the semantic model name.
   - Make sure the **Workspace** field is populated with the workspace where
     you want to save the semantic model.
   - If the **Workspace** field is blank and **Confirm** stays disabled,
     create the semantic model in a shared Fabric workspace where the
     workspace can be selected normally.
   - Select `dbo.orders_bronze`.
   - Select **Confirm**.
   - Add these DAX measures under the **Model** tab in the **Data** panel:
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

7. If you have Copilot enabled, test prompt-based query generation in
   **DAX query view**. Select **DAX query view**, press `Ctrl + I`, and enter
   one of these prompts:
   - `Show net sales by region as a clustered column chart.`
   - `Which product categories generate the highest gross margin?`
   - `Show monthly net sales trend by sales motion.`
   - `Which customer segments have the highest average discount percentage?`
   - `Show order count by support plan and deployment model.`

### Success Criteria

- `orders_bronze` contains about 1,000 rows after refresh.
- The semantic model updates and Copilot responds to the prompts.
