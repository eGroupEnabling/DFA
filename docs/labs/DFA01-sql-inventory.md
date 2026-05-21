## DFA01: Connect to SQL Server and Load Spaceship Inventory

**Objective**: Load a diverse 1,000-row spaceship-parts inventory table into
Azure SQL Database and use Fabric natural language query (NLQ) to analyze
inventory value, lead times, and low-stock parts.

**Assets used**:

- `samples/labs/DFA01-sample-data.sql`

**Estimated time**: 15-20 minutes

### Steps

1. Connect to your Azure SQL Database using SSMS, Azure Data Studio, or VS Code.
   When deployed, an SQL admin account will be created, such as
   `CloudSA6ee65c4a`. Use **Reset password** from the SQL Server blade in Azure,
   and make a note of both the account name and password when connecting to the
   database.

2. Open and run `samples/labs/DFA01-sample-data.sql`.
   This script creates `dbo.SpaceshipPartsInventory` and inserts 1,000 rows of
   sample inventory as shown in the results pane.

3. Validate data load with SQL:
   ```sql
   SELECT COUNT(*) AS PartCount FROM dbo.SpaceshipPartsInventory;

   SELECT TOP 10
       PartNumber,
       PartName,
       PartCategory,
       ShipClass,
       Manufacturer,
       WarehouseLocation,
       StockQuantity,
       ReorderPoint
   FROM dbo.SpaceshipPartsInventory
   ORDER BY (StockQuantity - ReorderPoint) ASC, UnitCost DESC;
   ```

4. In your Fabric workspace, create a semantic model from the SQL data:
   - Go to your Fabric workspace at `https://app.powerbi.com/groups/me/list`.
   - Select **New item** → **Semantic model**.
   - Choose **Get Data**, then select **Azure SQL Database** as the source.
   - Set the server. From the **SQL database** Azure blade, copy the
     **Server name**.
   - Set the database name, such as `sqldb-dfa-lab01`.
   - Use either **Basic** for SQL authentication with an account such as
     `CloudSA6ee65c4a`, or use your own **Organizational account**.
   - Select **Next**, then click the check mark next to
     `SpaceshipPartsInventory`.
   - Confirm the model has the numeric fields `StockQuantity`, `UnitCost`,
     `LeadTimeDays`, `FailureRatePct`, and `VendorRating`.
   - Select **Transform data**.
   - Select the down arrow next to **Create report** and **Create a semantic
     model only**.
   - Save the name, such as `SpaceshipPartsInventory`.

5. Add a measure in the semantic model:
   - First, select the **Model** tab within the **Data** panel on the right.
   - Select the **More options** dots next to **Measures (0)**, then select
     **New measure**. The cursor moves to the query input.
   - Clear the text, enter the following in the query input, and press `Enter`
     or select the green check mark:
   ```dax
   Inventory Value =
   SUMX(
       SpaceshipPartsInventory,
       SpaceshipPartsInventory[StockQuantity] * SpaceshipPartsInventory[UnitCost]
   )
   ```
   - On the right **Data** panel, under the **Model** tab, you should see the new
     `Inventory Value` measure.

6. Query with Fabric chat (NLQ) using prompts.
   **Note**: You must have a Copilot license and enable Copilot in your Fabric
   capacity.
   - On the left pane, select the **Copilot** icon.
   - In the chat box, click the `+` icon to add the
     `SpaceshipPartsInventory` semantic model.
   - Example prompts:
     - `Show inventory value by ship class as a bar chart.`
     - `Which part categories have the highest average lead time?`
     - `Show low-stock parts by warehouse location and mission criticality.`
     - `Which manufacturers have the highest total inventory value?`
     - `Find propulsion parts with the highest failure rate.`

### Success Criteria

- `SpaceshipPartsInventory` contains 1,000 rows.
- Fabric chat returns valid visuals/tables from your semantic model.
