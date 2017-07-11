-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	INSERT EXECUTE(SQL)

-- =============================================

-- 事先建立資料表或宣告一個資料表變數
DECLARE  @LogSpaceUsed table
	(
	[Database Name] sysname,
	[Log Size (MB)] float(7),
	[Log Space Used (%)]  float(7),
	[status] int
	);
 
INSERT @LogSpaceUsed
  EXEC('DBCC SQLPERF(LOGSPACE);')  

Select * from @LogSpaceUsed;



-- 利用linked server 無需事先建立資料表
sp_addlinkedserver @server = 'LOCALTEST',  @srvproduct = '',@provider = 'SQLOLEDB', @datasrc = @@servername

SELECT  *
INTO    #myTempTable
FROM    OPENQUERY(LOCALTEST, 'EXEC AdventureWorks2008R2.dbo.uspGetEmployeeManagers 2');

sp_dropserver  @server = 'LOCALTEST'