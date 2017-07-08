-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	資料表_筆數與大小.sql

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