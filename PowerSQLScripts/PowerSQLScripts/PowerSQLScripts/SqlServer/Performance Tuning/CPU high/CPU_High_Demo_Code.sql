-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	CPU_High_Demo_Code

-- =============================================

-- CPU High，但sqlservr.exe只用了不到10%
select  * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
union all select * from AdventureWorks2008R2.Sales.SalesOrderDetail
GO 100


-- CPU約 50% in task manager
-- Query to Keep CPU Busy for 30 Seconds
DECLARE @T DATETIME, @F BIGINT;
SET @T = GETDATE();
WHILE DATEADD(SECOND,30,@T)>GETDATE()
SET @F=POWER(2,30);

-- Query to Keep CPU Busy for 60 Seconds
DECLARE @T DATETIME, @F BIGINT;
SET @T = GETDATE();
WHILE DATEADD(SECOND,60,@T)>GETDATE()
SET @F=POWER(2,30);



USE AdventureWorks
GO
DECLARE @Flag INT
SET @Flag = 1
WHILE(@Flag < 1000)
BEGIN
ALTER INDEX [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] ON [Sales].[SalesOrderDetail] REBUILD
SET @Flag = @Flag + 1
END
GO