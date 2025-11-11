NEBANDYTA

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
