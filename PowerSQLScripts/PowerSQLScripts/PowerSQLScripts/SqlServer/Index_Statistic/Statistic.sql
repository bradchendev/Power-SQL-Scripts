-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Statistic 統計資訊
-- Statistics
-- https://docs.microsoft.com/en-us/sql/relational-databases/statistics/statistics
-- DBCC SHOW_STATISTICS (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-show-statistics-transact-sql
-- UPDATE STATISTICS (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/update-statistics-transact-sql
-- sys.dm_db_stats_properties (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-stats-properties-transact-sql
-- =============================================



--Statistics
--https://msdn.microsoft.com/en-us/library/ms190397.aspx

--DBCC SHOW_STATISTICS (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms174384.aspx
--A. Returning all statistics information
--The following example displays all statistics information for the AK_Address_rowguid index of the Person.Address table in the AdventureWorks2012 database.
DBCC SHOW_STATISTICS ("Person.Address", AK_Address_rowguid);  
GO  

--B. Specifying the HISTOGRAM option
--The following example limits the statistics information displayed for the AK_Address_rowguid index to the HISTOGRAM data.
DBCC SHOW_STATISTICS ("Person.Address", AK_Address_rowguid) WITH HISTOGRAM;  
GO  


--STATS_DATE (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms190330.aspx
--A. Return the dates of the most recent statistics for a table
--The following example returns the date of the most recent update for each statistics object on the Person.Address table.
USE AdventureWorks2012;  
GO  
SELECT name AS stats_name,   
    STATS_DATE(object_id, stats_id) AS statistics_update_date  
FROM sys.stats   
WHERE object_id = OBJECT_ID('Person.Address');  
GO  

--If statistics correspond to an index, the stats_id value in the sys.stats catalog view is the same as the index_id value in the sys.indexes catalog view, and the following query returns the same results as the preceding query. If statistics do not correspond to an index, they are in the sys.stats results but not in the sys.indexes results.
USE AdventureWorks2012;  
GO  
SELECT name AS index_name,   
    STATS_DATE(object_id, index_id) AS statistics_update_date  
FROM sys.indexes   
WHERE object_id = OBJECT_ID('Person.Address');  
GO  



--UPDATE STATISTICS (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187348.aspx

--Updating All Statistics with sp_updatestats
--For information about how to update statistics for all user-defined and internal tables in the database, see the stored procedure sp_updatestats (Transact-SQL). For example, the following command calls sp_updatestats to update all statistics for the database.
EXEC sp_updatestats;  


--A. Update all statistics on a table
--The following example updates the statistics for all indexes on the SalesOrderDetail table.
USE AdventureWorks2012;  
GO  
UPDATE STATISTICS Sales.SalesOrderDetail;  
GO  

--B. Update the statistics for an index
--The following example updates the statistics for the AK_SalesOrderDetail_rowguid index of the SalesOrderDetail table.
USE AdventureWorks2012;  
GO  
UPDATE STATISTICS Sales.SalesOrderDetail AK_SalesOrderDetail_rowguid;  
GO  

--C. Update statistics by using 50 percent sampling
--The following example creates and then updates the statistics for the Name and ProductNumber columns in the Product table.
USE AdventureWorks2012;  
GO  
CREATE STATISTICS Products  
    ON Production.Product ([Name], ProductNumber)  
    WITH SAMPLE 50 PERCENT  
-- Time passes. The UPDATE STATISTICS statement is then executed.  
UPDATE STATISTICS Production.Product(Products)   
    WITH SAMPLE 50 PERCENT;  

--D. Update statistics by using FULLSCAN and NORECOMPUTE
--The following example updates the Products statistics in the Product table, forces a full scan of all rows in the Product table, and turns off automatic statistics for the Products statistics.
USE AdventureWorks2012;  
GO  
UPDATE STATISTICS Production.Product(Products)  
    WITH FULLSCAN, NORECOMPUTE;  
GO  