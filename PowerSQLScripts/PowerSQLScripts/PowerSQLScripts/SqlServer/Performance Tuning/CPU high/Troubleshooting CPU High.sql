-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Troubleshooting CPU High

-- =============================================



-- CPU Usage High
-- status = running and cpu_time increase
--
--大量reqesut的Wait_type = SOS_SCHEDULER_YIELD
-- SOS_SCHEDULER_YIELD represents a SQLOS worker (thread) that has yielded the CPU, presumably to another worker.
-- Task有worker
-- 
--或
--大量reqesut的Status = RUNNABLE

SELECT TOP 20 req.session_id,se.
[program_name],se.[host_name],
req.cpu_time,req.start_time,
req.status,req.wait_type,
req.command,
req.blocking_session_id,
sqltext.text as [Parent Query],
SUBSTRING(sqltext.text, req.statement_start_offset / 2, (CASE
    WHEN req.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), sqltext.text)) * 2
    ELSE req.statement_end_offset
  END - req.statement_start_offset) / 2) as  [Individual Query]
from sys.dm_exec_requests req
inner join sys.dm_exec_sessions se on req.session_id = se.session_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
order by req.cpu_time DESC
GO


-- 含執行計畫
SELECT TOP 20 req.session_id,se.
[program_name],se.[host_name],
req.cpu_time,req.start_time,
req.status,req.wait_type,
req.command,
req.blocking_session_id,
sqltext.text as [Parent Query],
SUBSTRING(sqltext.text, req.statement_start_offset / 2, (CASE
    WHEN req.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), sqltext.text)) * 2
    ELSE req.statement_end_offset
  END - req.statement_start_offset) / 2) as  [Individual Query],
execPlan.query_plan
from sys.dm_exec_requests req
inner join sys.dm_exec_sessions se on req.session_id = se.session_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
CROSS APPLY sys.dm_exec_query_plan(req.plan_handle) as execPlan
order by req.cpu_time DESC
GO



-- Many individual queries that cumulatively consume high CPU
PRINT '-- top 10 Active CPU Consuming Queries (aggregated)--';
SELECT TOP 10 GETDATE() runtime, *
FROM (SELECT query_stats.query_hash, SUM(query_stats.cpu_time) 'Total_Request_Cpu_Time_Ms', SUM(logical_reads) 'Total_Request_Logical_Reads', MIN(start_time) 'Earliest_Request_start_Time', COUNT(*) 'Number_Of_Requests', SUBSTRING(REPLACE(REPLACE(MIN(query_stats.statement_text), CHAR(10), ' '), CHAR(13), ' '), 1, 256) AS "Statement_Text"
    FROM (SELECT req.*, SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1) AS statement_text
          FROM sys.dm_exec_requests AS req
                CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST ) AS query_stats
    GROUP BY query_hash) AS t
ORDER BY Total_Request_Cpu_Time_Ms DESC;


-- Long running queries that consume CPU are still running
PRINT '--top 10 Active CPU Consuming Queries by sessions--';
SELECT TOP 10 req.session_id, req.start_time, cpu_time 'cpu_time_ms', OBJECT_NAME(ST.objectid, ST.dbid) 'ObjectName', SUBSTRING(REPLACE(REPLACE(SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1), CHAR(10), ' '), CHAR(13), ' '), 1, 512) AS statement_text
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
ORDER BY cpu_time DESC;
GO





-- Poor API cursor
-- concurrent session using poor API cursor
SELECT creation_time, cursor_id, name, cur.session_id, login_name   
FROM sys.dm_exec_cursors(0) AS cur   
JOIN sys.dm_exec_sessions AS s ON cur.session_id = s.session_id   
where
    cur.fetch_buffer_size = 1 
    and cur.properties LIKE 'API%'	-- API cursor (Transact-SQL cursors always have a fetch buffer of 1)
--WHERE DATEDIFF(hh, c.creation_time, GETDATE()) > 36;  
GO  






--sys.dm_exec_cursors (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms190346.aspx
--Troubleshooting Performance Problems in SQL Server 2008
--https://technet.microsoft.com/en-us/library/dd672789(v=sql.100).aspx

--Run the following query to get the TOP 50 cached plans that consumed the most cumulative CPU
--All times are in microseconds
SELECT TOP 50 qs.creation_time, qs.execution_count, qs.total_worker_time as total_cpu_time, qs.max_worker_time as max_cpu_time, 
qs.total_elapsed_time, qs.max_elapsed_time, qs.total_logical_reads, qs.max_logical_reads, qs.total_physical_reads, 
qs.max_physical_reads,t.[text], qp.query_plan, t.dbid, t.objectid, t.encrypted, qs.plan_handle, qs.plan_generation_num
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY qs.total_worker_time DESC
 




 -- The CPU issue occurred in the past
 -- If the issue occurred in the past and you want to do root cause analysis, 
 -- use Query Store. Users with database access can use T-SQL to query Query Store data. 
 -- Query Store default configurations use a granularity of 1 hour. 
 -- Use the following query to look at activity for high CPU consuming queries. 
 -- This query returns the top 15 CPU consuming queries. 
 -- Remember to change rsi.start_time >= DATEADD(hour, -2, GETUTCDATE():

 -- Top 15 CPU consuming queries by query hash
-- note that a query  hash can have many query id if not parameterized or not parameterized properly
-- it grabs a sample query text by min
WITH AggregatedCPU AS (SELECT q.query_hash, SUM(count_executions * avg_cpu_time / 1000.0) AS total_cpu_millisec, SUM(count_executions * avg_cpu_time / 1000.0)/ SUM(count_executions) AS avg_cpu_millisec, MAX(rs.max_cpu_time / 1000.00) AS max_cpu_millisec, MAX(max_logical_io_reads) max_logical_reads, COUNT(DISTINCT p.plan_id) AS number_of_distinct_plans, COUNT(DISTINCT p.query_id) AS number_of_distinct_query_ids, SUM(CASE WHEN rs.execution_type_desc='Aborted' THEN count_executions ELSE 0 END) AS Aborted_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Regular' THEN count_executions ELSE 0 END) AS Regular_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Exception' THEN count_executions ELSE 0 END) AS Exception_Execution_Count, SUM(count_executions) AS total_executions, MIN(qt.query_sql_text) AS sampled_query_text
                       FROM sys.query_store_query_text AS qt
                            JOIN sys.query_store_query AS q ON qt.query_text_id=q.query_text_id
                            JOIN sys.query_store_plan AS p ON q.query_id=p.query_id
                            JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id=p.plan_id
                            JOIN sys.query_store_runtime_stats_interval AS rsi ON rsi.runtime_stats_interval_id=rs.runtime_stats_interval_id
                       WHERE rs.execution_type_desc IN ('Regular', 'Aborted', 'Exception')AND rsi.start_time>=DATEADD(HOUR, -2, GETUTCDATE())
                       GROUP BY q.query_hash), OrderedCPU AS (SELECT query_hash, total_cpu_millisec, avg_cpu_millisec, max_cpu_millisec, max_logical_reads, number_of_distinct_plans, number_of_distinct_query_ids, total_executions, Aborted_Execution_Count, Regular_Execution_Count, Exception_Execution_Count, sampled_query_text, ROW_NUMBER() OVER (ORDER BY total_cpu_millisec DESC, query_hash ASC) AS RN
                                                              FROM AggregatedCPU)
SELECT OD.query_hash, OD.total_cpu_millisec, OD.avg_cpu_millisec, OD.max_cpu_millisec, OD.max_logical_reads, OD.number_of_distinct_plans, OD.number_of_distinct_query_ids, OD.total_executions, OD.Aborted_Execution_Count, OD.Regular_Execution_Count, OD.Exception_Execution_Count, OD.sampled_query_text, OD.RN
FROM OrderedCPU AS OD
WHERE OD.RN<=15
ORDER BY total_cpu_millisec DESC;





-- from query_stats
SELECT  creation_time  
        ,last_execution_time 
        ,total_physical_reads
        ,total_logical_reads  
        ,total_logical_writes
        , execution_count 
        , total_worker_time
        , total_elapsed_time 
        , total_elapsed_time / execution_count avg_elapsed_time
        ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
         ((CASE statement_end_offset 
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END 
            - qs.statement_start_offset)/2) + 1) AS [Individual Query],
 st.text as [Parent Query],
 qp.query_plan 
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
ORDER BY total_elapsed_time / execution_count DESC
GO

-- from query_stats
-- group by plan_handle  and order by sum(qs.total_worker_time) desc
SELECT a.total_cpu_time,a.total_execution_count
,a.number_of_statements,sqltext.text,
 qp.query_plan 
 FROM 
(
select top 50 
    sum(qs.total_worker_time) as total_cpu_time, 
    sum(qs.execution_count) as total_execution_count,
    count(*) as  number_of_statements, 
    qs.plan_handle 
from 
    sys.dm_exec_query_stats qs
    group by qs.plan_handle
order by sum(qs.total_worker_time) desc
) a 
cross apply sys.dm_exec_sql_text(a.plan_handle) as sqltext
CROSS APPLY sys.dm_exec_query_plan(a.plan_handle) qp 
GO



-- Figure 7 Identifying top 20 most expensive queries in terms of read I/O
SELECT TOP 20 SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,  
        ((CASE qs.statement_end_offset 
          WHEN -1 THEN DATALENGTH(qt.text) 
         ELSE qs.statement_end_offset 
         END - qs.statement_start_offset)/2)+1),  
qs.execution_count,  
qs.total_logical_reads, qs.last_logical_reads, 
qs.min_logical_reads, qs.max_logical_reads, 
qs.total_elapsed_time, qs.last_elapsed_time, 
qs.min_elapsed_time, qs.max_elapsed_time, 
qs.last_execution_time, 
qp.query_plan 
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
WHERE qt.encrypted=0 
ORDER BY qs.total_logical_reads DESC 
 









 -- if Multi SQL Instance
SELECT SERVERPROPERTY('processid') as [Process ID]
GO

-- CPU Core Count
select cpu_count from sys.dm_os_sys_info;
GO
select scheduler_id,cpu_id, status, is_online from sys.dm_os_schedulers where status='VISIBLE ONLINE';
GO

EXEC sp_readerrorlog 6, 1, 'detected'
-- 2016-05-11 09:26:31.070	Server	Detected 8 CPUs. This is an informational message; no user action is required.

-- four parameters:
--Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
--Log file type: 1 or NULL = error log, 2 = SQL Agent log
--Search string 1: String one you want to search for
--Search string 2: String two you want to search for to further refine the results


-- CPU Usage
DECLARE @ms_ticks_now BIGINT
SELECT @ms_ticks_now = ms_ticks
FROM sys.dm_os_sys_info;
SELECT TOP 15 record_id
	,dateadd(ms, - 1 * (@ms_ticks_now - [timestamp]), GetDate()) AS EventTime
	,SQLProcessUtilization
	,SystemIdle
	,100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
FROM (
	SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
		,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization
		,TIMESTAMP
	FROM (
		SELECT TIMESTAMP
			,convert(XML, record) AS record
		FROM sys.dm_os_ring_buffers
		WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '%<SystemHealth>%'
		) AS x
	) AS y
ORDER BY record_id DESC

