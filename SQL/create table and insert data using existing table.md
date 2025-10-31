
If both tables have identical column order and types:
```
INSERT INTO target_table
SELECT *
FROM source_table;
```
If both tables have identical column order:
```
INSERT INTO target_table (column1, column2, column3)
SELECT column1, column2, column3
FROM source_table
WHERE condition;
```

If you have a table called employees and want to make a full copy (new table and data):
```
SELECT *
INTO employees_backup
FROM employees;
```



Insert one row:
```
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```
Insert multiple rows:
```
INSERT INTO table_name (column1, column2)
VALUES 
  (value1a, value2a),
  (value1b, value2b),
  (value1c, value2c);
```

