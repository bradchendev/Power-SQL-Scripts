-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	ERRORLOG AGENTLOG 查詢Errorlog  and Agent log
-- View the SQL Server Error Log (SQL Server Management Studio)
-- https://docs.microsoft.com/en-us/sql/relational-databases/performance/view-the-sql-server-error-log-sql-server-management-studio
-- SQL Server Agent Error Log
-- https://docs.microsoft.com/en-us/sql/ssms/agent/sql-server-agent-error-log
-- =============================================

-- 執行sp_readerrorlog 裡面是call xp_readerrorlog

--CREATE PROC [sys].[sp_readerrorlog]( 
--   @p1     INT = 0, 
--   @p2     INT = NULL, 
--   @p3     VARCHAR(255) = NULL, 
--   @p4     VARCHAR(255) = NULL) 
--AS 
--BEGIN 

--   IF (NOT IS_SRVROLEMEMBER(N'securityadmin') = 1) 
--   BEGIN 
--      RAISERROR(15003,-1,-1, N'securityadmin') 
--      RETURN (1) 
--   END 
    
--   IF (@p2 IS NULL) 
--       EXEC sys.xp_readerrorlog @p1 
--   ELSE 
--       EXEC sys.xp_readerrorlog @p1,@p2,@p3,@p4 
--END


-- 讀取目前的ERRORLOG
EXEC sp_readerrorlog

-- 讀取封存的第一個的ERRORLOG，也就是ERRORLOG.1
EXEC sp_readerrorlog 1


EXEC sp_readerrorlog 6, 1, 'detected'
-- 2016-05-11 09:26:31.070	Server	Detected 8 CPUs. This is an informational message; no user action is required.

-- four parameters:
--Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
--Log file type: 1 or NULL = error log, 2 = SQL Agent log
--Search string 1: String one you want to search for
--Search string 2: String two you want to search for to further refine the results



-- 也可直接call xp_readerrorlog
EXEC master.dbo.xp_readerrorlog 6, 1, '2005', 'exec', NULL, NULL, N'desc' 
EXEC master.dbo.xp_readerrorlog 6, 1, '2005', 'exec', NULL, NULL, N'asc'
--xp_readerrrorlog
--Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
--Log file type: 1 or NULL = error log, 2 = SQL Agent log
--Search string 1: String one you want to search for
--Search string 2: String two you want to search for to further refine the results
--Search from start time  
--Search to end time
--Sort order for results: N'asc' = ascending, N'desc' = descending