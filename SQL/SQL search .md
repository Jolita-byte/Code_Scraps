
Find a column name in all tables:

# my SQL
```
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%YourColumnName%';
```

# SQL
```
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.schemas s
JOIN sys.tables t ON s.schema_id = t.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.name LIKE '%YourColumnName%';
```

# search in procedures views

```sql
  SELECT sm.object_id,
       o.type_desc,
       s.name AS schema_name,
       o.name AS object_name,
       sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o ON sm.object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE sm.definition LIKE '%vw_Remontas%'
```

# get list of columns

```sql
SELECT
    c.name AS ColumnName,
    t.name AS DataType,
    c.is_nullable
FROM
    sys.views v
JOIN
    sys.columns c ON v.object_id = c.object_id
JOIN
    sys.types t ON c.user_type_id = t.user_type_id
WHERE
    v.name = 'YourViewName';
```

```
  AND o.type IN ('P', 'V'); -- P = Procedure, V = View
