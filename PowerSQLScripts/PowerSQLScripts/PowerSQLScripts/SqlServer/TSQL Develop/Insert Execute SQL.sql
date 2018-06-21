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





--Msg 8164, Level 16, State 1, Procedure SQLSentryPerformanceCounterCPU, Line 66
--An INSERT EXEC statement cannot be nested.

-- 利用linked server 無需事先建立資料表
-- 不一定能成功，要看SP裡面的寫法
sp_addlinkedserver @server = 'LOCALTEST',  @srvproduct = '',@provider = 'SQLOLEDB', @datasrc = @@servername

SELECT  *
INTO    #myTempTable
FROM    OPENQUERY(LOCALTEST, 'EXEC AdventureWorks2008R2.dbo.uspGetEmployeeManagers 2');

sp_dropserver  @server = 'LOCALTEST'


-- 這種SP sp_helprotect就會失敗
sp_addlinkedserver @server = 'LOCALTEST',  @srvproduct = '',@provider = 'SQLOLEDB', @datasrc = @@servername

select * INTO #tempTable FROM OPENQUERY(LOCALTEST, 'EXECUTE sp_helprotect NULL, ''QA'' ');

sp_dropserver  @server = 'LOCALTEST'

--Msg 208, Level 16, State 1, Procedure sp_helprotect, Line 129
--Invalid object name '#t1_Prots'.



-- 另一種可以試試
sp_configure 'Show Advanced Options', 1
GO
RECONFIGURE
GO
sp_configure 'Ad Hoc Distributed Queries', 1
GO
RECONFIGURE
GO

SELECT * INTO #TempTable FROM OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;',
     'EXEC AdventureWorks2008R2.dbo.uspGetEmployeeManagers 2')

SELECT * FROM #TempTable

-- 上述方法，如果用sp_helprotect還是會失敗
--Msg 208, Level 16, State 1, Procedure sp_helprotect, Line 129
--Invalid object name '#t1_Prots'.
