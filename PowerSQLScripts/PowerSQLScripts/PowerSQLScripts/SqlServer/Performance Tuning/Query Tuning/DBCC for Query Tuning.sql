-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	DBCC for Query Tuning

-- =============================================



DBCC DROPCLEANBUFFERS;
GO
DBCC FREEPROCCACHE;
GO



DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

--A.從計畫快取清除查詢計劃
--下列範例會從計畫快取中指定查詢計劃控制代碼，藉以清除查詢計劃。 為確保範例查詢位於計畫快取中，會先執行查詢。 系統會查詢 sys.dm_exec_cached_plans 和 sys.dm_exec_sql_text 動態管理檢視以傳回查詢的計畫控制代碼。 然後會將結果集中的計畫控制代碼值插入到 DBCC FREEPROCACHE 陳述式中，就可以從計畫快取中僅移除該計畫。
USE AdventureWorks2012;  
GO  
SELECT * FROM Person.Address;  
GO  
SELECT plan_handle, st.text  
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st  
WHERE text LIKE N'SELECT * FROM Person.Address%';  
GO  
--以下為結果集：
--plan_handle text
---------------------------------------------------- -----------------------------
--0x060006001ECA270EC0215D05000000000000000000000000 SELECT * FROM Person.Address;
--(1 row(s) affected)

-- Remove the specific plan from the cache.  
DBCC FREEPROCCACHE (0x060006001ECA270EC0215D05000000000000000000000000);  
GO



-- Find uspGetMyData SP plan cache
DECLARE @cache_plan_handle varbinary(44)
SELECT @cache_plan_handle = c.plan_handle
FROM 
 sys.dm_exec_cached_plans c
 CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) t
WHERE 
 text like 'CREATE%uspGetMyData%' 
-- Never run DBCC FREEPROCCACHE without a parameter in production unless you want to lose all of your cached plans...
DBCC FREEPROCCACHE(@cache_plan_handle)