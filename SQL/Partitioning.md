NEBANDYTA
TODO: Reikia sutvarkyti turinį
 [TOC]
 
# Table of Contents
1. [Partitioning Chat GBT](#Partitioning_Chat_GBT)
2. [How to find existing partitions](#find_partitions)


# Partitioning Chat GBT <a name="Partitioning_Chat_GBT"></a>
## Prompt: if i have past 30 days data, and i want update it, i want old 30 days data to be deleted, and uloaded new. while using switch out for older than 3 months data

Perfect — you’re describing a **very common hybrid pattern** for managing large, time-based tables in SQL Server (and Azure SQL).

Let’s break it into **two coordinated processes** — one for *refreshing recent data* (the last 30 days), and another for *archiving older data (3+ months)* — both using best practices around **partition switching** and **metadata-level efficiency**.

---

## 🧭 Your goal

You want to:

1. Keep **only the last 3 months** of data in the main table.
2. **Archive anything older** than 3 months using `SWITCH OUT`.
3. **Refresh** (fully replace) the last 30 days with newly loaded data.

---

## 🧩 Recommended Architecture

You should partition your main fact table by **day** or **month** on a date column, e.g. `RecordDate`.

Example:

```sql
CREATE PARTITION FUNCTION pfDataRange (DATE)
AS RANGE RIGHT FOR VALUES
(
  '2025-08-31', '2025-09-30', '2025-10-31', '2025-11-30'
);

CREATE PARTITION SCHEME psDataScheme
AS PARTITION pfDataRange ALL TO ([PRIMARY]);

CREATE TABLE dbo.FactData
(
  RecordID INT IDENTITY(1,1) PRIMARY KEY,
  RecordDate DATE NOT NULL,
  Value DECIMAL(18,2)
)
ON psDataScheme(RecordDate);
```

---

## ⚙️ Step 1 – **Switch out old data (older than 3 months)**

Every month, you archive one partition (the one older than 3 months).

Example:

```sql
-- Determine which partition to switch out (August 2025)
CREATE TABLE dbo.FactData_Archive_202508
(
  RecordID INT,
  RecordDate DATE,
  Value DECIMAL(18,2)
)
WITH (CHECK (RecordDate >= '2025-08-01' AND RecordDate <= '2025-08-31'));

ALTER TABLE dbo.FactData
SWITCH PARTITION 1 TO dbo.FactData_Archive_202508;
```

✅ Now, August 2025 data lives in the archive table — removed from the main table instantly.

---

## ⚙️ Step 2 – **Refresh the past 30 days**

You can’t use `SWITCH OUT` directly for rolling 30-day windows (since partitions are monthly), but you can handle this safely with a **truncate + reload** approach.

1. Create a **staging table** for the past 30 days:

   ```sql
   CREATE TABLE dbo.FactData_Staging (
       RecordID INT,
       RecordDate DATE,
       Value DECIMAL(18,2)
   );
   ```

2. Load new 30-day data into `FactData_Staging` (from your source system).

3. **Delete only the last 30 days** from your main table:

   ```sql
   DELETE FROM dbo.FactData
   WHERE RecordDate >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE));
   ```

4. Insert the refreshed data:

   ```sql
   INSERT INTO dbo.FactData (RecordDate, Value)
   SELECT RecordDate, Value
   FROM dbo.FactData_Staging;
   ```

5. Truncate the staging table:

   ```sql
   TRUNCATE TABLE dbo.FactData_Staging;
   ```

---

## ⚡ Combining both processes

Here’s what your **monthly job** should do:

1. **Archive old partitions (older than 3 months)**
   → Use `SWITCH OUT` for entire months.

2. **Refresh last 30 days**
   → Use `DELETE + INSERT` or, if your partition granularity allows, a `SWITCH IN` from a staging table.

---

## ✅ Why this works perfectly

* Fast archive using **partition switching** (metadata only).
* Safe 30-day refresh using **controlled deletion**.
* Keeps your main table **light and optimized**.
* Avoids full table scans or locking large ranges.
* Easy to automate via **SQL Agent** or **ADF pipeline**.

---

## 🧠 Optional optimization

If your business always works in **daily partitions** instead of monthly, you could make this even cleaner:

* Switch out one day at a time for rolling refresh.
* No deletes at all — purely metadata switches.

Would you like me to show a version of this process using **daily partitions and automatic script generation (for ADF or SQL Agent)**? It’s cleaner for 30-day rolling updates.

## Prompt: Yes

Perfect ✅ — let’s go through how to implement a **fully automated daily-partitioned table** that:

1. **Keeps only the last 90 days** of data (older data is switched out & archived),
2. **Refreshes the last 30 days** each day with new/updated data,
3. Is **fully automatable** via **Azure Data Factory (ADF)** or **SQL Agent**.

---

## 🧩 1. Table Design — Daily Partitioning

First, define your partitioning so each day has its own partition.
This makes it easy to switch out (archive or refresh) individual days.

```sql
-- Partition function: one partition per day
CREATE PARTITION FUNCTION pfDataRange (DATE)
AS RANGE RIGHT FOR VALUES (
    '2025-08-01', '2025-08-02', '2025-08-03', '2025-08-04', ... -- up to 90 days ahead
);

CREATE PARTITION SCHEME psDataScheme
AS PARTITION pfDataRange ALL TO ([PRIMARY]);
```

Then, create your main fact table:

```sql
CREATE TABLE dbo.FactData
(
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    RecordDate DATE NOT NULL,
    Value DECIMAL(18,2)
)
ON psDataScheme(RecordDate);
```

---

## ⚙️ 2. Daily Automation Logic

Every day, you’ll run a SQL job or ADF pipeline that:

### Step A — Identify key dates

```sql
DECLARE 
    @Today DATE = CAST(GETDATE() AS DATE),
    @ArchiveDate DATE = DATEADD(DAY, -90, GETDATE()),   -- older than 90 days → archive
    @RefreshStart DATE = DATEADD(DAY, -30, GETDATE());  -- last 30 days → refresh
```

---

### Step B — Switch out data older than 90 days

Create a small archive table dynamically, switch old data out instantly, and store it:

```sql
DECLARE @ArchiveTableName NVARCHAR(128) = 'FactData_Archive_' + CONVERT(VARCHAR(8), @ArchiveDate, 112);
DECLARE @SQL NVARCHAR(MAX) = N'';

SET @SQL = N'
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = ''' + @ArchiveTableName + ''')
        SELECT TOP 0 * INTO dbo.' + QUOTENAME(@ArchiveTableName) + ' FROM dbo.FactData;

    ALTER TABLE dbo.FactData
    SWITCH PARTITION ' + CAST($PARTITION.pfDataRange(@ArchiveDate) AS NVARCHAR(10)) + 
    ' TO dbo.' + QUOTENAME(@ArchiveTableName) + ';';

EXEC sp_executesql @SQL;
```

✅ This moves the oldest day’s data into an archive table (metadata only, instant operation).

---

### Step C — Refresh last 30 days

Use a **staging table** for incoming data (ADF can populate it):

```sql
CREATE TABLE dbo.FactData_Staging
(
    RecordDate DATE,
    Value DECIMAL(18,2)
);
```

Load your new data (for the past 30 days) into this staging table.

Then:

1. **Delete existing data** from the main table for the last 30 days:

   ```sql
   DELETE FROM dbo.FactData
   WHERE RecordDate >= @RefreshStart;
   ```

2. **Insert refreshed data**:

   ```sql
   INSERT INTO dbo.FactData (RecordDate, Value)
   SELECT RecordDate, Value
   FROM dbo.FactData_Staging;
   ```

3. **Truncate staging**:

   ```sql
   TRUNCATE TABLE dbo.FactData_Staging;
   ```

---

### Step D — Maintain partition boundaries

Since you’re keeping a 90-day rolling window, each day you’ll need to:

* **Drop** the oldest partition boundary.
* **Add** a new one for tomorrow’s date.

Example:

```sql
ALTER PARTITION FUNCTION pfDataRange()
SPLIT RANGE (DATEADD(DAY, 1, @Today));   -- add new day partition
ALTER PARTITION FUNCTION pfDataRange()
MERGE RANGE (@ArchiveDate);               -- remove oldest partition
```

---

## ⚡ 3. Automating with ADF

In **Azure Data Factory**, your pipeline would look like this:

1. **Lookup** activity → determine @ArchiveDate, @RefreshStart, @Today.
2. **Stored Procedure** activity → run the SQL logic above (archive + refresh).
3. **Copy Activity** → load refreshed data into `FactData_Staging`.
4. **Script Activity** → truncate the staging table after insertion.

This can be scheduled **daily**.

---

## ✅ Final Behavior Summary

| Task                                    | Frequency | Result                          |
| --------------------------------------- | --------- | ------------------------------- |
| Switch out partition older than 90 days | Daily     | Archives data safely            |
| Delete + reload last 30 days            | Daily     | Keeps data current              |
| Add/drop partitions dynamically         | Daily     | Maintains 90-day rolling window |
| Archive tables compressed or exported   | Optional  | Keeps storage low               |

---

## 🧠 Why this pattern works best

* 🔹 **No downtime** — all metadata-level changes.
* 🔹 **No big deletes** — deletes only recent small window (30 days).
* 🔹 **Fast archiving** — switch out in milliseconds.
* 🔹 **ADF-ready** — can be parameterized and run automatically.
* 🔹 **Auditable** — archived data still queryable.

---

Would you like me to give you the **exact stored procedure** you can deploy in SQL Server (or Azure SQL DB) to do this entire process automatically?
It would handle the archive, partition maintenance, and refresh in one go.


# Partitioning Gemini
## Prompt: my problem is to delete data from table, to update them with new ones. how to do this with partitions
I understand now. You are looking for a **"Sling Load"** or **"Partition Switching"** strategy. Instead of deleting millions of rows row-by-row (which is slow and locks the table), you want to drop an entire "bucket" of data (like one month) and swap in the new data instantly.

To make this possible in T-SQL, you don't just use the `OVER(PARTITION BY...)` function; you must physically set up the table to be **Partitioned**.

### Step 1: Create a Partition Function

This defines the "boundaries" (e.g., the dates) that separate your data buckets.

```sql
CREATE PARTITION FUNCTION MonthRangeFunction (DATE)
AS RANGE RIGHT FOR VALUES ('2026-01-01', '2026-02-01', '2026-03-01');

```

### Step 2: Create a Partition Scheme

This maps those "buckets" to the physical storage (filegroups) in your database.

```sql
CREATE PARTITION SCHEME MonthRangeScheme
AS PARTITION MonthRangeFunction
ALL TO ([PRIMARY]);

```

### Step 3: Create/Modify the Table to use the Scheme

Your table must be built on this scheme to allow for fast "deletes."

```sql
CREATE TABLE Finance_Sink (
    full_name NVARCHAR(255) COLLATE Lithuanian_CI_AS, -- Unicode for Kęstutis
    pasikrovimo_data DATE,
    Pajamos DECIMAL(18,2)
) ON MonthRangeScheme (pasikrovimo_data);

```

---

### How to "Delete and Update" with Partitions

Once the table is set up this way, you can "clear" a specific month almost instantly without a `DELETE` command:

#### 1. Truncate a specific Partition

If you just received new data for **January 2026** and want to wipe the old January data:

```sql
-- Assuming January is partition 2
TRUNCATE TABLE Finance_Sink WITH (PARTITIONS (2));

```

* **Why this is better**: It doesn't log every row deletion, so it is nearly instant and won't crash your transaction log.

#### 2. The "Switch" Method (Advanced)

If you want **zero downtime**, you load your new data into a "Staging" table first, then swap them:

```sql
ALTER TABLE Staging_Table SWITCH PARTITION 1 TO Finance_Sink PARTITION 2;

```

### Summary of Benefits for your Project

* **Efficiency**: Deleting one month of data for all companies (like "Kęstutis Arlauskas") takes milliseconds regardless of the number of rows.
* **Maintenance**: You can rebuild indexes on just the newest partition instead of the whole 10-year history.
* **Data Integrity**: By truncating the partition before the "sink," you guarantee there are no duplicates for that specific time period in your Power BI Matrix.

**Would you like the SQL script to help you identify which partition number corresponds to which month in your current table?**

# Dynamic partitioning

Yes, you can absolutely make partitioning dynamic. T-SQL does not have an "auto-partition" setting that creates new months by itself, but you can use a **Stored Procedure** to automate the process.

To handle new months as they appear, you use two specific commands: `SPLIT` (to add a new month) and `MERGE` (to remove or archive old months).

---

### 1. How to "Split" a Partition for a New Month

When a new month starts (e.g., February 2026), you need to "split" the last partition to create a new boundary.

```sql
-- 1. Check your existing Scheme to see where the data goes
-- 2. Use ALTER PARTITION FUNCTION to add the new date
ALTER PARTITION FUNCTION MonthRangeFunction() 
SPLIT RANGE ('2026-02-01');

```

> **Note:** For this to work, you must have an empty "Next Used" filegroup in your Partition Scheme.

### 2. Automating it with a Stored Procedure

Instead of doing this manually every month, you can create a script that checks if a partition for the "Next Month" exists and creates it if it doesn't.

```sql
CREATE PROCEDURE dbo.sp_AutomatePartitions
AS
BEGIN
    DECLARE @NextMonth DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    SET @NextMonth = DATEADD(MONTH, 1, @NextMonth); -- Target the start of next month

    -- Only split if the boundary doesn't exist yet
    IF NOT EXISTS (SELECT 1 FROM sys.partition_range_values rv 
                   JOIN sys.partition_functions pf ON rv.function_id = pf.function_id
                   WHERE pf.name = 'MonthRangeFunction' AND rv.value = @NextMonth)
    BEGIN
        -- Ensure the scheme knows where to put the new data
        ALTER PARTITION SCHEME MonthRangeScheme NEXT USED [PRIMARY];
        
        -- Create the new boundary
        ALTER PARTITION FUNCTION MonthRangeFunction() SPLIT RANGE (@NextMonth);
    END
END

```

---

### 3. Best Practices for your "Sink" Workflow

* **Pre-Creation:** Always create partitions for 6–12 months into the future. This prevents your "Sink" from failing if the automated script hasn't run yet.
* **Unicode Names:** When the partition logic runs, it doesn't affect the data itself, so your Lithuanian names like **"Kęstutis"** will remain safe as long as the underlying table is `NVARCHAR`.
* **Truncate Before Update:** Now that it's dynamic, your update logic becomes:
1. Identify the partition number for the month you are uploading.
2. `TRUNCATE TABLE YourTable WITH (PARTITIONS (X))`.
3. Insert new data.



### 4. Monitoring your Partitions

You can find these dynamic changes in the same place I mentioned before: **Storage > Partition Functions**. If you run the automation, you will see the list of "Boundary Values" grow there automatically.

**Would you like me to help you write the logic to find the specific Partition Number for a given date so your "Delete/Update" script knows exactly which one to truncate?**

# How to find existing partitions <a name="find_partitions"></a>

## 1. Finding them in SSMS (Object Explorer)
To see your created partitions, follow this path in the Object Explorer panel on the left:

Open your Database.

Expand the Storage folder.

Inside Storage, you will find two specific folders:

Partition Functions: Contains the logic defining the boundaries (e.g., your dates).

Partition Schemes: Contains the mapping of those functions to filegroups.

## 2. Finding them using SQL Queries
If you want to see the details (like which dates or values are defined) using a script, you can query the system views:

To see all Partition Functions:

```SQL

SELECT * FROM sys.partition_functions;
```
To see all Partition Schemes:

```SQL

SELECT * FROM sys.partition_schemes;
```
To see which Table is using which Partition: This is very helpful to verify that your "Finance Sink" table is correctly linked to the scheme:

```SQL

SELECT 
    t.name AS TableName, 
    ps.name AS PartitionScheme, 
    pf.name AS PartitionFunction
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
WHERE t.name = 'Your_Table_Name'; -- Replace with your sink table name

```
## 3. Checking Partition Boundaries
Since you need to delete/truncate specific data (like a specific month), you need to know which Partition Number corresponds to which date. Use this query:

```SQL

SELECT 
    p.partition_number, 
    p.rows, 
    rv.value AS BoundaryValue
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_range_values rv ON ps.function_id = rv.function_id AND p.partition_number = rv.boundary_id
WHERE object_name(p.object_id) = 'Your_Table_Name';
```

# Dynamic partition identification
To find the specific partition numbers used by your table (specifically the last two), you need to query `sys.partitions`. Since partition numbers are assigned sequentially, the "last" partitions correspond to the highest partition numbers.

### The SQL Query

This script identifies the two highest partition numbers currently containing (or reserved for) data in your `tracking_fact` table:

```sql
SELECT TOP 2
    p.partition_number,
    p.rows AS RowCount,
    rv.value AS BoundaryValue
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values rv 
    ON pf.function_id = rv.function_id 
    AND p.partition_number = (CASE WHEN pf.boundary_value_on_right = 1 THEN rv.boundary_id + 1 ELSE rv.boundary_id END)
WHERE p.object_id = OBJECT_ID('Fleethand.tracking_fact')
  AND i.type <= 1 -- 0: Heap, 1: Clustered (Only check the base data)
ORDER BY p.partition_number DESC;

```

---

### Understanding the Results

1. **The "Last" Partition (Highest Number):**
In a `RANGE RIGHT` function, the highest partition number is the **"catch-all"** bucket. It holds everything greater than or equal to your last defined date. In the query above, the `BoundaryValue` for this partition will often appear as `NULL` because it has no upper limit.
2. **The Second to Last Partition:**
This is usually the partition for your **most recent month** (e.g., January 2026).

---

### Why you need these for your "Update" logic

When you want to perform a `SWITCH` or a `TRUNCATE`, you must provide the **exact partition number**.

If you are using the **Staging Table** method we discussed, your logic would look like this:

* **Partition N:** The empty future bucket.
* **Partition N-1:** The bucket you just loaded with your latest Lithuanian fleet data.

### Pro-Tip: Dynamic Partition Identification

If you want to find the partition number for a **specific date** (so you don't have to guess which one is "last"), use the `$PARTITION` function:

```sql
DECLARE @TargetDate DATETIME2 = '2026-01-01';

SELECT $PARTITION.pf_Monthly_datetime2(@TargetDate) AS TargetPartitionNumber;

```

*This is the safest way to ensure your `TRUNCATE` hits the correct month without accidentally wiping the wrong data.*

**Would you like me to show you how to use this `$PARTITION` function inside an automated script to clear the current month's data?**
