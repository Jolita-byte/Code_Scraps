-- Randame nuo kada pradėti partitionus
SELECT MIN(timestamp) FROM Fleethand.tracking_fact -- 2024-07-07 12:30:34.0000000

-------------------nenaudota
/*CREATE PARTITION FUNCTION pf_Monthly (datetime)
AS RANGE RIGHT FOR VALUES ('2026-01-01', '2026-02-01', '2026-03-01');*/



------- sukuriame particijos funkciją. Dinamiškai sugeneruojam jai startinius intervalus
DECLARE @StartDate DATETIME2 = '2024-01-01';
DECLARE @EndDate DATETIME2 = GETDATE(); --DATEADD(MONTH, 6, GETDATE()); -- Creates boundaries up to 6 months from now
DECLARE @Values NVARCHAR(MAX) = '';

-- Loop to generate the string of dates
WHILE @StartDate <= @EndDate
BEGIN
    SET @Values = @Values + '''' + FORMAT(@StartDate, 'yyyy-MM-dd HH:mm:ss.fffffff') + ''',';
    SET @StartDate = DATEADD(MONTH, 1, @StartDate);
END

-- Remove the trailing comma
SET @Values = LEFT(@Values, LEN(@Values) - 1);

select @Values
-- Construct and execute the CREATE command
DECLARE @SQL NVARCHAR(MAX) = '
CREATE PARTITION FUNCTION pf_Monthly_datetime2 (DATETIME2)
AS RANGE RIGHT FOR VALUES (' + @Values + ');';

EXEC sp_executesql @SQL;


--------------- sukuriame particijos schemą
CREATE PARTITION SCHEME ps_Monthly_datetime2
AS PARTITION pf_Monthly_datetime2
ALL TO ([PRIMARY]);

----- pasidarome lentelės backupą
Select * into Fleethand.tracking_fact_backup_2026_01_08 from Fleethand.tracking_fact -- (18163331 rows affected) Completion time: 2026-01-08T16:39:43.7959239+02:00 truko 26 minutes
Select * into Fleethand.tracking_fact_partitions from Fleethand.tracking_fact

------priskiriame schemą lentelei kaip indeksą
CREATE CLUSTERED INDEX CX_tracking_fact
ON [Fleethand].[tracking_fact] ([timestamp], id)
ON ps_Monthly_datetime2 ([timestamp]);

--truko 36 min

-- ------- sukurtų particijų pasitikrinimui

SELECT 
    p.partition_number, 
    p.rows, 
    rv.value AS BoundaryValue
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_range_values rv ON ps.function_id = rv.function_id AND p.partition_number = rv.boundary_id +1
WHERE object_name(p.object_id) = 'tracking_fact';


--------naujo intervalo įterpimas
DECLARE @StartDate DATETIME2;
SET @StartDate = (
	SELECT TOP 1
		CAST (value as DATETIME2)
	FROM sys.partition_range_values rv
	JOIN sys.partition_functions pf ON rv.function_id = pf.function_id
	WHERE pf.name = 'pf_Monthly_datetime2'
	ORDER BY boundary_id DESC);

SET @StartDate = DATEADD(MONTH, 1, @StartDate);

DECLARE @EndDate DATETIME2 = GETDATE(); --DATEADD(MONTH, 6, GETDATE()); -- Creates boundaries up to 6 months from now

WHILE @StartDate < @EndDate
BEGIN
	ALTER PARTITION SCHEME ps_Monthly_datetime2 NEXT USED [PRIMARY];
    ALTER PARTITION FUNCTION pf_Monthly_datetime2() SPLIT RANGE (@StartDate);
    SET @StartDate = DATEADD(MONTH, 1, @StartDate);
END

-------------- particijos šalinimas prieš įterpiant naujus duomenis


--Šaliname particijas nuo datos
DECLARE @FilterDate DATETIME2 = DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
--Iki data randama pagal funkcijoje egzistuojančias particijas
DECLARE @MaxDate DATETIME2 = (
    SELECT MAX(CAST(value AS DATETIME2)) 
    FROM sys.partition_range_values rv
    JOIN sys.partition_functions pf ON rv.function_id = pf.function_id
    WHERE pf.name = 'pf_Monthly_datetime2'
);

DECLARE @PartitionNumber INT;

WHILE @FilterDate <= @MaxDate
BEGIN
    SET @PartitionNumber = NULL;
    SET @PartitionNumber = $PARTITION.pf_Monthly_datetime2(@FilterDate);
    SELECT @PartitionNumber AS CurrentPartition, @FilterDate AS ForDate;
	--TRUNCATE TABLE Fleethand.tracking_fact_partitions WITH (PARTITIONS (@PartitionNumber));
    SET @FilterDate = DATEADD(MONTH, 1, @FilterDate);
END	

---------------Pasitikriname iki kada yra likę duomenys
select MAX(timestamp) from Fleethand.tracking_fact_partitions
------------------------
