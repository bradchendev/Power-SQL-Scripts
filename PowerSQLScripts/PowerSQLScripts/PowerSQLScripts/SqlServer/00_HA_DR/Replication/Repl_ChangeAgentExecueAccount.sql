-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/5/18
-- Description:	change Replication Agent execute account (Job Runas(proxy account))
--  PS.如果用SSMS UI設定複寫時指定執行帳戶，則會大量建立Credential, Proxy Account，使用以下SQL語法，可以各自共用一組Credential, Proxy Account

-- =============================================

USE [master]
GO
CREATE CREDENTIAL [[REPL]][CONTOSO\SQLReplLogR01]]] 
WITH IDENTITY = N'CONTOSO\SQLReplLogR01', 
SECRET = N'SQLReplLogR01Password'
GO
CREATE CREDENTIAL [[REPL]][CONTOSO\SQLReplLogR02]]] 
WITH IDENTITY = N'CONTOSO\SQLReplLogR02', 
SECRET = N'SQLReplLogR02Password'
GO

CREATE CREDENTIAL [[REPL]][CONTOSO\SQLRepl001]]] 
WITH IDENTITY = N'CONTOSO\SQLRepl001', 
SECRET = N'SQLRepl001Password'
GO
CREATE CREDENTIAL [[REPL]][CONTOSO\SQLRepl002]]] 
WITH IDENTITY = N'CONTOSO\SQLRepl002', 
SECRET = N'SQLRepl002Password'
GO



USE [msdb]
GO
-- for Replication Distributor
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][CONTOSO\SQLRepl001]',@credential_name=N'[REPL][CONTOSO\SQLRepl001]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][CONTOSO\SQLRepl001]', @subsystem_id=6
GO
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][CONTOSO\SQLRepl002]',@credential_name=N'[REPL][CONTOSO\SQLRepl002]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][CONTOSO\SQLRepl002]', @subsystem_id=6
GO



-- for Replication Snapshot
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR01]',@credential_name=N'[REPL][CONTOSO\SQLReplLogR01]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR01]', @subsystem_id=4
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR01]', @login_name=N'distributor_admin'
GO
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR02]',@credential_name=N'[REPL][CONTOSO\SQLReplLogR02]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR02]', @subsystem_id=4
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR02]', @login_name=N'distributor_admin'
GO


-- for Replication Transaction-Log Reader
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR01]',@credential_name=N'[REPL][CONTOSO\SQLReplLogR01]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR01]', @subsystem_id=5
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR01]', @login_name=N'distributor_admin'
GO

EXEC msdb.dbo.sp_add_proxy @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR02]',@credential_name=N'[REPL][CONTOSO\SQLReplLogR02]', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR02]', @subsystem_id=5
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR02]', @login_name=N'distributor_admin'
GO




-- Replication Log Reader Agent - change Job Proxy Account
USE [msdb]
GO

DECLARE @jobid uniqueidentifier
select @jobid = job_id from distribution.dbo.MSlogreader_agents where publisher_db = 'AdventureWorks2008R2'
EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR01]'
WAITFOR DELAY '00:00:01'
EXEC sp_stop_job @job_id = @jobid;
WAITFOR DELAY '00:00:05'
EXEC sp_start_job @job_id = @jobid;
GO


DECLARE @jobid uniqueidentifier
select @jobid = job_id from distribution.dbo.MSlogreader_agents where publisher_db = 'Northwind'
EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][LOGR][CONTOSO\SQLReplLogR02]'
WAITFOR DELAY '00:00:01'
EXEC sp_stop_job @job_id = @jobid;
WAITFOR DELAY '00:00:05'
EXEC sp_start_job @job_id = @jobid;
GO



-- Snapshot Agent - AdventureWorks2008R2
-- select * from distribution.dbo.MSsnapshot_agents where publisher_db = 'AdventureWorks2008R2';

DECLARE @jobid uniqueidentifier

DECLARE @RowID INT = 1, @MaxRowID INT;
CREATE TABLE #ReplAgents ( RowID int, job_id uniqueidentifier );

INSERT INTO #ReplAgents ( RowID, job_id)
SELECT ROW_NUMBER() 
        OVER (ORDER BY job_id) AS Row, job_id
from distribution.dbo.MSsnapshot_agents where publisher_db = 'AdventureWorks2008R2';

SELECT @MaxRowID = MAX(RowID) FROM #ReplAgents
WHILE @RowID <= @MaxRowID
BEGIN
	select @jobid = job_id from #ReplAgents where RowID = @RowID

	EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR01]'
	--WAITFOR DELAY '00:00:01'
	--EXEC sp_stop_job @job_id = @jobid;
	--WAITFOR DELAY '00:00:05'
	--EXEC sp_start_job @job_id = @jobid;
	
    SET @RowID = @RowID + 1;
END
DROP TABLE #ReplAgents;


-- Snapshot Agent - Northwind
-- select * from distribution.dbo.MSsnapshot_agents where publisher_db = 'Northwind';

DECLARE @jobid uniqueidentifier

DECLARE @RowID INT = 1, @MaxRowID INT;
CREATE TABLE #ReplAgents ( RowID int, job_id uniqueidentifier );

INSERT INTO #ReplAgents ( RowID, job_id)
SELECT ROW_NUMBER() 
        OVER (ORDER BY job_id) AS Row, job_id
from distribution.dbo.MSsnapshot_agents where publisher_db = 'Northwind';

SELECT @MaxRowID = MAX(RowID) FROM #ReplAgents
WHILE @RowID <= @MaxRowID
BEGIN
	select @jobid = job_id from #ReplAgents where RowID = @RowID

	EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][SNSAP][CONTOSO\SQLReplLogR02]'
	--WAITFOR DELAY '00:00:01'
	--EXEC msdb.dbo.sp_stop_job @job_id = @jobid;
	--WAITFOR DELAY '00:00:05'
	--EXEC msdb.dbo.sp_start_job @job_id = @jobid;
	
    SET @RowID = @RowID + 1;
END
DROP TABLE #ReplAgents;



-- Distribution Agent - AdventureWorks2008R2 - TPECOGCM2
-- select * from distribution.dbo.MSdistribution_agents where publisher_db = 'AdventureWorks2008R2';

DECLARE @jobid uniqueidentifier

DECLARE @RowID INT = 1, @MaxRowID INT;
CREATE TABLE #ReplAgents ( RowID int, job_id uniqueidentifier );

INSERT INTO #ReplAgents ( RowID, job_id)
SELECT ROW_NUMBER() 
        OVER (ORDER BY job_id) AS Row, job_id
from distribution.dbo.MSdistribution_agents where publisher_db = 'AdventureWorks2008R2';

SELECT @MaxRowID = MAX(RowID) FROM #ReplAgents
WHILE @RowID <= @MaxRowID
BEGIN
	select @jobid = job_id from #ReplAgents where RowID = @RowID

	EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][CONTOSO\SQLRepl001]'

	WAITFOR DELAY '00:00:01'
	EXEC msdb.dbo.sp_stop_job @job_id = @jobid;
	WAITFOR DELAY '00:00:05'
	EXEC msdb.dbo.sp_start_job @job_id = @jobid;
	
    SET @RowID = @RowID + 1;
END
DROP TABLE #ReplAgents;



-- Distribution Agent - Northwind - TPECOGCM2
-- select * from distribution.dbo.MSdistribution_agents where publisher_db = 'Northwind';

DECLARE @jobid uniqueidentifier

DECLARE @RowID INT = 1, @MaxRowID INT;
CREATE TABLE #ReplAgents ( RowID int, job_id uniqueidentifier );

INSERT INTO #ReplAgents ( RowID, job_id)
SELECT ROW_NUMBER() 
        OVER (ORDER BY job_id) AS Row, job_id
from distribution.dbo.MSdistribution_agents where publisher_db = 'Northwind';

SELECT @MaxRowID = MAX(RowID) FROM #ReplAgents
WHILE @RowID <= @MaxRowID
BEGIN
	select @jobid = job_id from #ReplAgents where RowID = @RowID

	EXEC msdb.dbo.sp_update_jobstep @job_id=@jobid, @step_id=2 , @proxy_name=N'[REPL][CONTOSO\SQLRepl002]'

	WAITFOR DELAY '00:00:01'
	EXEC msdb.dbo.sp_stop_job @job_id = @jobid;
	WAITFOR DELAY '00:00:05'
	EXEC msdb.dbo.sp_start_job @job_id = @jobid;
	
    SET @RowID = @RowID + 1;
END
DROP TABLE #ReplAgents;


