## 💡 What is TREATAS?

The `TREATAS` function is a powerful table function in DAX that applies the filter context of one set of columns to a completely different set of columns, *as if* a relationship existed between them.

It takes values from one or more columns and applies them as filters to corresponding columns in another table.

### Analogy

Think of `TREATAS` like temporarily **creating a fake filter relationship** for the duration of a single measure calculation, without needing to create a permanent relationship in your data model.

### Syntax

```dax
TREATAS(
    <table_expression>, -- The table/column(s) containing the filter values you want to apply
    <column>[, <column>[, ...]] -- The column(s) in the target table where the filter should be applied
)
```

-----

## 🎯 TREATAS DAX Example

A common use case for `TREATAS` is to apply filters from a disconnected lookup table (like a separate table for budgeting or scenario analysis) to a fact table.

### Scenario

Suppose you have a simple data model with two tables that are **not** related:

1.  **`'Sales'` Table:** Contains transaction data with a column for `[ProductCode]`.
2.  **`'Sales Budget'` Table:** Contains budget targets with a column for `[Budget Product Code]`.

You want to calculate the total sales for only the products listed in the 'Sales Budget' table.

### DAX Measure using TREATAS

We will use the distinct product codes from the `'Sales Budget'` table and apply them as a filter to the `[ProductCode]` column in the `'Sales'` table.

```dax
Total Sales for Budgeted Products =
CALCULATE(
    SUM('Sales'[SalesAmount]),
    -- Use TREATAS to apply the filter
    TREATAS(
        VALUES('Sales Budget'[Budget Product Code]), -- The values to use as a filter
        'Sales'[ProductCode]                         -- The column to apply the filter to
    )
)
```

### Explanation

1.  **`VALUES('Sales Budget'[Budget Product Code])`**: This extracts a list of unique product codes (e.g., {"P101", "P105", "P110"}) from the budget table.
2.  **`TREATAS(...)`**: This takes that list of product codes and instructs DAX to filter the `'Sales'[ProductCode]` column *as if* an actual filter of "P101 or P105 or P110" was applied to the `Sales` table.
3.  **Result**: The measure returns the sum of `[SalesAmount]` for only those products that exist in the budget table's product list.

This technique is often more efficient than using `FILTER` with `LOOKUPVALUE` or `INTERSECT` for this type of cross-table filtering.
