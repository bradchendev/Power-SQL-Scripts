-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	資料表筆數與大小_Row_Size

-- =============================================


-- 筆數
--SQL Server–HOW-TO: quickly retrieve accurate row count for table
--https://blogs.msdn.microsoft.com/martijnh/2010/07/15/sql-serverhow-to-quickly-retrieve-accurate-row-count-for-table/

--Recently, I’ve been involved in a very interesting project in which we need to perform operations on a table containing 3,000,000,000+ rows. For some tooling, I needed a quick and reliable way to count the number of rows contained within this table. Performing a simple

--SELECT COUNT(*) FROM Transactions
--operation would do the trick on small tables with low IO, but what’s the ‘best’ way (quick and reliable) to perform this operation on large tables?

--I searched and found different answers, which I note here so it might be of use to someone… (My table was called ‘Transactions’)


--1.Performs a full table scan. Slow on large tables.
SELECT COUNT(*) FROM Transactions;


--2. Fast way to retrieve row count. Depends on statistics and is inaccurate.
--Run DBCC UPDATEUSAGE(Database) WITH COUNT_ROWS, which can take significant time for large tables.
SELECT CONVERT(bigint, rows)
FROM sysindexes
WHERE id = OBJECT_ID('Transactions')
AND indid < 2


--The way the SQL management studio counts rows (look at table properties, storage, row count). Very fast, but still an approximate number of rows.
SELECT CAST(p.rows AS float)
FROM sys.tables AS tbl
INNER JOIN sys.indexes AS idx ON idx.object_id = tbl.object_id and idx.index_id < 2
INNER JOIN sys.partitions AS p ON p.object_id=CAST(tbl.object_id AS int)
AND p.index_id=idx.index_id
WHERE ((tbl.name=N'Transactions'
AND SCHEMA_NAME(tbl.schema_id)='dbo'))


--Quick (although not as fast as method 2) operation and equally important, reliable.
SELECT SUM (row_count)
FROM sys.dm_db_partition_stats
WHERE object_id=OBJECT_ID('Transactions')   
AND (index_id=0 or index_id=1);




-- All Table row_count
USE AdventureWorks
GO
select [Schema],[Table], SUM(row_count) as [row_count] 
from 
(
SELECT part.object_id,part.row_count, SCHEMA_NAME(tb.schema_id) as [Schema], tb.name as [Table]
FROM sys.dm_db_partition_stats part
inner join sys.tables tb
on part.object_id = tb.object_id
where (index_id=0 or index_id=1)
) a
group by [Schema],[Table]


--大小
--資料表大小
--from standard report [Disk Usage by TOP Tables]


exec sp_executesql @stmt=N'begin try 

			SELECT TOP 1000
			(row_number() over(order by (a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1,
			a3.name AS [schemaname],
			a2.name AS [tablename],
			a1.rows as row_count,
			(a1.reserved + ISNULL(a4.reserved,0))* 8 AS [Reserved(KB)],
			a1.data * 8 AS [Data(KB)],
			(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS [Indexes(KB)],
			(CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS [Unused(KB)]
			FROM
			(SELECT
			ps.object_id,
			SUM (
			CASE
			WHEN (ps.index_id < 2) THEN row_count
			ELSE 0
			END
			) AS [rows],
			SUM (ps.reserved_page_count) AS reserved,
			SUM (
			CASE
			WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
			ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
			END
			) AS data,
			SUM (ps.used_page_count) AS used
			FROM sys.dm_db_partition_stats ps
			GROUP BY ps.object_id) AS a1
			LEFT OUTER JOIN
			(SELECT
			it.parent_id,
			SUM(ps.reserved_page_count) AS reserved,
			SUM(ps.used_page_count) AS used
			FROM sys.dm_db_partition_stats ps
			INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
			WHERE it.internal_type IN (202,204)
			GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
			INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
			INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
			WHERE a2.type <> N''S'' and a2.type <> N''IT''
			end try
			begin catch
			select
			-100 as l1
			,	1 as schemaname
			,       ERROR_NUMBER() as tablename
			,       ERROR_SEVERITY() as row_count
			,       ERROR_STATE() as reserved
			,       ERROR_MESSAGE() as data
			,       1 as index_size
			, 		1 as unused
			end catch',@params=N''



-- 目前column設計的max size

--Maximum Size of Index Keys
--https://technet.microsoft.com/en-us/library/ms191241(v=sql.105).aspx
--SELECT SUM(max_length)AS TotalIndexKeySize
--FROM sys.columns
--WHERE name IN (N'AddressLine1', N'AddressLine2', N'City', N'StateProvinceID', N'PostalCode')
--AND object_id = OBJECT_ID(N'Person.Address');

SELECT SUM(max_length) AS RowMaxSize_bytes
FROM sys.columns
WHERE [object_id] = OBJECT_ID(N'Sales.SalesOrderHeader');


SELECT col.name, typ.name as [DataType], col.max_length
FROM sys.columns	col 
inner join sys.types typ
	on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id
WHERE [object_id] = OBJECT_ID(N'Sales.SalesOrderHeader');

-- sys.columns.max_length = -1  ->  (max)
-- max indicates that the maximum storage size is 2^31-1 bytes (2 GB)

-- nchar(50) = 50 bytes = unicode所以儲存佔用空間為50 bytes x2 = 100 Bytes

--nchar and nvarchar (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms186939.aspx
--nchar [ ( n ) ]
--Fixed-length Unicode string data. n defines the string length and must be a value from 1 through 4,000. The storage size is two times n bytes. When the collation code page uses double-byte characters, the storage size is still n bytes. Depending on the string, the storage size of n bytes can be less than the value specified for n. The ISO synonyms for nchar are national char and national character..
--nvarchar [ ( n | max ) ]
--Variable-length Unicode string data. n defines the string length and can be a value from 1 through 4,000. max indicates that the maximum storage size is 2^31-1 bytes (2 GB). The storage size, in bytes, is two times the actual length of data entered + 2 bytes. The ISO synonyms for nvarchar are national char varying and national character varying.






-- 目前的資料裡面max row size
-- 新版
SELECT min_record_size_in_bytes,
max_record_size_in_bytes,
avg_record_size_in_bytes
 FROM sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2008R2'), OBJECT_ID(N'[Sales].[SalesOrderHeader]'), NULL, NULL , 'DETAILED')

SELECT min_record_size_in_bytes,
max_record_size_in_bytes,
avg_record_size_in_bytes
 FROM sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2008R2'), OBJECT_ID(N'[Sales].[SalesOrderHeader]'), NULL, NULL , 'DETAILED')
--PS.在DEV3測試查詢耗時



-- 舊版
dbcc showcontig ('SalesOrderHeader') with tableresults
--MinimumRecordSize	Minimum record size in that level of the index or whole heap.
--MaximumRecordSize Maximum record size in that level of the index or whole heap.