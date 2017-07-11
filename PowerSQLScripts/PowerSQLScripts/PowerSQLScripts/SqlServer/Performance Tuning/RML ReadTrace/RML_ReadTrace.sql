-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	  RML Utilities 
-- Cumulative Update 1 to the RML Utilities for Microsoft SQL Server Released
-- https://blogs.msdn.microsoft.com/psssql/2008/11/12/cumulative-update-1-to-the-rml-utilities-for-microsoft-sql-server-released/
-- =============================================

-- 未完全確認此語法的準確性 (可能需要再Join其他資料表或group by)
-- 只透過TABLE的屬性來判斷來產生此SQL Query
SELECT 
     (select OrigText from ReadTrace.tblUniqueBatches where hashId = a.hashId)
     ,(select NormText from ReadTrace.tblUniqueBatches where hashId = a.hashId)   
      ,SUM(CPU) as [CPU]
		,COUNT(*) as [count]
  FROM [ReadTraceDB20161116202501].[ReadTrace].[tblBatches] a
	inner join [ReadTrace].[tblUniqueBatches] b
	on a.HashID = b.HashID
  where (
		a.startTime > '2016-11-16 20:29:50.000'
		and
		a.startTime < '2016-11-16 20:32:00.000'
		)	
	GROUP BY a.HashID
	having SUM(CPU) > 20000
	order by SUM(CPU) DESC
	
	