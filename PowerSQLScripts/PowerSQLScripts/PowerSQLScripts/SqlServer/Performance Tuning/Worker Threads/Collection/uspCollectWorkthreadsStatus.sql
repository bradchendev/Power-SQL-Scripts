USE [DBA]
GO

/****** Object:  StoredProcedure [Perf].[uspCollectWorkthreadsStatus]    Script Date: 12/28/2016 10:04:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [Perf].[uspCollectWorkthreadsStatus]
AS
-- Create by Brad
DECLARE @CollectTime nvarchar(23)
SET @CollectTime = CONVERT(nvarchar(23), GETDATE(), 121)

DECLARE @SQL nvarchar(2000)
SET @SQL = N'select * from openquery([db2.tutorabc.com],''
select 
''''' + @CollectTime + N''''' as [CollectTime],
 @@SERVERNAME as [ServerName],
sqlserver_start_time,
max_workers_count,
stack_size_in_bytes,
cpu_count,
scheduler_count,
physical_memory_in_bytes,
virtual_memory_in_bytes,
bpool_committed,bpool_commit_target
from sys.dm_os_sys_info'')'

insert into DBA.Perf.Collect_dm_os_sys_info
EXEC(@SQL)


SET @SQL = N'select * from openquery([db2.tutorabc.com],''
SELECT 
''''' + @CollectTime + N''''' as [CollectTime],
 @@SERVERNAME as [ServerName],
 SUM(current_workers_count) as [Current worker thread] 
FROM sys.dm_os_schedulers'')'
insert into DBA.Perf.Collect_Current_worker_thread
EXEC(@SQL)

SET @SQL = N'select * from openquery([db2.tutorabc.com],''
SELECT  
''''' + @CollectTime + N''''' as [CollectTime],
 @@SERVERNAME as [ServerName],
	t.session_id ,
  COUNT(*) as [COUNT]
FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
GROUP BY t.session_id
order by COUNT(*) DESC'')'

INSERT into DBA.Perf.Collect_worker_thread_usage_by_Requests  
EXEC(@SQL)


SET @SQL = N'select * from openquery([db2.tutorabc.com],''
select 
''''' + @CollectTime + N''''' as [CollectTime],
 @@SERVERNAME as [ServerName],
sysp.spid,
st.text as [Parent Query],
sysp.hostname,
sysp.loginame,
sysp.program_name,
sysp.status,
sysp.waittype,
sysp.waitresource,
sysp.kpid,
sysp.blocked
from sys.sysprocesses sysp
CROSS APPLY sys.dm_exec_sql_text(sysp.sql_handle) AS st'')'

insert into DBA.Perf.Collect_sessions_status
EXEC(@SQL)


GO

