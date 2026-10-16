## EDU02: Load Higher-Ed Student CSV from Azure Storage into OneLake

**Objective**: Load a richer higher-education student success CSV from Azure Data
Lake Storage Gen2 (ADLS Gen2) into OneLake, then expose it through a semantic
model for Copilot-assisted exploration of enrollment, GPA, retention, and
financial aid.

This lab mirrors the data that a higher-ed Student Information System (SIS) or
student-success platform such as Banner, PeopleSoft, Workday Student, or
Navigate would export: a denormalized enrollment record with academics,
residency, financial aid, retention, and LMS-engagement attributes. All data is
synthetic.

**Assets used**:

- `samples/labs/EDU02-students.csv`

**Estimated time**: 30-40 minutes

### Steps

1. Upload `samples/labs/EDU02-students.csv` to the `raw` container in your
   deployed storage account.
   The deployment creates this storage account as ADLS Gen2 and provisions the
   `raw` container for landing files.
   This file contains about 1,000 student enrollment records with academic,
   demographic, residency, financial-aid, retention, and engagement attributes.

2. In a Fabric workspace, select **New item**, then create a new **Lakehouse**
   named `EDU02`.

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
   - Select the `raw` container, confirm that `EDU02-students.csv` is visible,
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
     `EDU02-students.csv`.
   - Let Power Query create the navigation steps until the preview shows the
     CSV row data.
   - In **Data destination** settings, choose the `EDU02` Lakehouse and set
     the table name to `students_bronze`.
   - Leave column mapping on **Automatic settings**, then select
     **Save settings**.
   - Select **Save and run**. The initial run can take up to a minute.
   - Optional: After the first run completes, open **Recent runs**. To enable
     scheduled refresh, select **Schedule refresh**, then select
     **+ Add schedule** and choose an interval such as every 15 minutes. Close
     the schedule window and the Dataflow to save your changes.

5. Validate ingestion in the **SQL analytics endpoint**. Use the
   **Analyze data with** dropdown at the top left of the `EDU02` Lakehouse:

   ```sql
   SELECT
       COUNT(*) AS TotalRowCount,
       COUNT(DISTINCT StudentNumber) AS StudentCount,
       COUNT(DISTINCT Major) AS MajorCount
   FROM dbo.students_bronze;

   SELECT TOP 10
       StudentNumber,
       FirstName,
       LastName,
       EnrollmentTerm,
       ClassStanding,
       College,
       Major,
       GPA,
       EnrollmentStatus,
       ResidencyStatus,
       TuitionBilled,
       FinancialAidAward,
       TuitionBilled - FinancialAidAward AS NetTuition
   FROM dbo.students_bronze
   ORDER BY GPA DESC, StudentID DESC;
   ```

6. Create a semantic model:
   - Open the `EDU02` **Lakehouse** or **SQL analytics endpoint**.
   - Select **New semantic model** from that item.
   - Enter `sm_students` as the semantic model name.
   - Make sure the **Workspace** field is populated with the workspace where
     you want to save the semantic model.
   - If the **Workspace** field is blank and **Confirm** stays disabled,
     create the semantic model in a shared Fabric workspace where the
     workspace can be selected normally.
   - Select `dbo.students_bronze`.
   - Select **Confirm**.
   - Add these DAX measures under the **Model** tab in the **Data** panel:

   ```dax
   Enrolled Students =
   CALCULATE(
       COUNTROWS(students_bronze),
       students_bronze[EnrollmentStatus] = "Enrolled"
   )

   Retention Rate =
   DIVIDE(
       CALCULATE(
           COUNTROWS(students_bronze),
           students_bronze[RetentionFlag] = "Yes"
       ),
       COUNTROWS(students_bronze)
   )

   Net Tuition Revenue =
   SUM(students_bronze[TuitionBilled])
       - SUM(students_bronze[FinancialAidAward])
   ```

7. If you have Copilot enabled, test prompt-based query generation in
   **DAX query view**. Select **DAX query view**, press `Ctrl + I`, and enter
   one of these prompts:
   - `Show enrolled student count by college as a clustered column chart.`
   - `Which majors have the highest average GPA?`
   - `Show retention rate by class standing and residency status.`
   - `Compare net tuition revenue by college and modality.`
   - `Show average financial aid award by first-generation status.`

### Success Criteria

- `students_bronze` contains about 1,000 rows after refresh.
- The semantic model updates and Copilot responds to the prompts.
