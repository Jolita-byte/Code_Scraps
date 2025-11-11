

Copy only schema (Columns and Data Types Only)
```sql
-- 1. Specify a new table name (NewTable)
-- 2. Select all columns (*) from the source table (OldTable)
-- 3. The WHERE 1 = 0 condition ensures the query returns NO ROWS, 
--    so only the structure is copied, not the data.

SELECT * INTO dbo.NewTableStructureOnly
FROM dbo.OldTable
WHERE 1 = 0;
```

✅ Pros - Very quick, single statement, creates the new table and its columns/data types instantly. 

❌ Cons - Does not copy constraints (Primary Keys, Foreign Keys, Unique Keys, Check Constraints), Indexes, or Triggers. You must create these manually afterward. 


A very common, slightly cleaner alternative to `WHERE 1 = 0` is using `TOP 0`. It achieves the exact same result as Method 1 (copies columns/data types, but no constraints/indexes).

```sql
SELECT TOP 0 * INTO dbo.NewTableWithTop0
FROM dbo.OldTable;
```

If both tables have identical column order and types:
```sql
INSERT INTO target_table
SELECT *
FROM source_table;
```
If both tables have identical column order:
```sql
INSERT INTO target_table (column1, column2, column3)
SELECT column1, column2, column3
FROM source_table
WHERE condition;
```

If you have a table called employees and want to make a full copy (new table and data):
```sql
SELECT *
INTO employees_backup
FROM employees;
```



Insert one row:
```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```
Insert multiple rows:
```sql
INSERT INTO table_name (column1, column2)
VALUES 
  (value1a, value2a),
  (value1b, value2b),
  (value1c, value2c);
```

