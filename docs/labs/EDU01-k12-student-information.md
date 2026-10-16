## EDU01: Connect to SQL Server and Load K-12 Student Information

**Objective**: Load a 1,000-row K-12 student information table into Azure SQL
Database and use Fabric natural language query (NLQ) to analyze enrollment,
attendance, grades, and assessment performance across schools and districts.

This lab mirrors the data that a K-12 Student Information System (SIS) such as
PowerSchool, Infinite Campus, or Skyward would export: a denormalized student
roster with demographics, enrollment, attendance, GPA, and state-assessment
scores. All data is synthetic.

**Assets used**:

- `samples/labs/EDU01-sample-data.sql`

**Estimated time**: 15-20 minutes

### Steps

1. Connect to your Azure SQL Database using SSMS, Azure Data Studio, or VS Code.
   When deployed, an SQL admin account will be created, such as
   `CloudSA6ee65c4a`. Use **Reset password** from the SQL Server blade in Azure,
   and make a note of both the account name and password when connecting to the
   database.

2. Open and run `samples/labs/EDU01-sample-data.sql`.
   This script creates `dbo.StudentInformation` and inserts 1,000 rows of
   synthetic K-12 student data as shown in the results pane.

3. Validate the data load with SQL:

   ```sql
   SELECT COUNT(*) AS StudentCount FROM dbo.StudentInformation;

   SELECT TOP 10
       StudentNumber,
       FirstName,
       LastName,
       GradeLevel,
       SchoolName,
       SchoolLevel,
       EnrollmentStatus,
       AttendanceRatePct,
       GPA,
       PerformanceLevel
   FROM dbo.StudentInformation
   WHERE EnrollmentStatus = 'Active'
   ORDER BY AttendanceRatePct ASC, GPA ASC;
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
     `StudentInformation`.
   - Confirm the model has the numeric fields `AttendanceRatePct`, `GPA`,
     `AbsenceDays`, `TardyCount`, `MathScore`, `ReadingScore`, and
     `ScienceScore`.
   - Select **Transform data**.
   - Select the down arrow next to **Create report** and **Create a semantic
     model only**.
   - Save the name, such as `StudentInformation`.

5. Add measures in the semantic model:
   - First, select the **Model** tab within the **Data** panel on the right.
   - Select the **More options** dots next to **Measures (0)**, then select
     **New measure**. The cursor moves to the query input.
   - Clear the text, enter the following in the query input, and press `Enter`
     or select the green check mark:

   ```dax
   Active Students =
   CALCULATE(
       COUNTROWS(StudentInformation),
       StudentInformation[EnrollmentStatus] = "Active"
   )
   ```

   - Repeat to add a second measure that flags students who may need
     intervention (chronic absenteeism combined with a low GPA):

   ```dax
   At Risk Students =
   CALCULATE(
       COUNTROWS(StudentInformation),
       FILTER(
           StudentInformation,
           StudentInformation[EnrollmentStatus] = "Active"
               && StudentInformation[AttendanceRatePct] < 90
               && StudentInformation[GPA] < 2.0
       )
   )
   ```

   - On the right **Data** panel, under the **Model** tab, you should see the new
     `Active Students` and `At Risk Students` measures.

6. Query with Fabric chat (NLQ) using prompts.
   **Note**: You must have a Copilot license and enable Copilot in your Fabric
   capacity.
   - On the left pane, select the **Copilot** icon.
   - In the chat box, click the `+` icon to add the
     `StudentInformation` semantic model.
   - Example prompts:
     - `Show active student count by school level as a bar chart.`
     - `Which schools have the lowest average attendance rate?`
     - `Show at-risk students by grade level and ethnicity.`
     - `Compare average GPA by school level and gender.`
     - `Which districts have the highest percentage of English learners?`
     - `Show average math, reading, and science scores by performance level.`

### Success Criteria

- `StudentInformation` contains 1,000 rows.
- The `Active Students` and `At Risk Students` measures return values in the
  semantic model.
- Fabric chat returns valid visuals/tables from your semantic model.
