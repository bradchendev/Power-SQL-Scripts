-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Current Requests, Sessions, Connections 目前的連線與狀態
-- sys.dm_exec_requests (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-requests-transact-sql
-- sys.dm_exec_sessions (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql
-- sys.dm_exec_connections (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-connections-transact-sql
-- =============================================


set transaction isolation level read uncommitted


-- Baisc query for current requests and session
select 
se.session_id, 
req.blocking_session_id,
se.status,
req.status,
req.wait_type,
req.wait_time,
se.host_name,
se.program_name,
se.last_request_start_time,
se.last_request_end_time,
st.text as [Parent Query],
SUBSTRING(st.text, (req.statement_start_offset/2)+1,
((CASE req.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE req.statement_end_offset
END - req.statement_start_offset)/2) + 1) AS statement_text
from sys.dm_exec_sessions se
inner Join sys.dm_exec_connections con on se.session_id=con.session_id and se.is_user_process = 1
Left join sys.dm_exec_requests req on req.session_id = se.session_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS st
order by req.cpu_time DESC
GO

-- 含執行計畫 Baisc query for current requests and session
select 
se.session_id, 
se.status,
req.status,
req.wait_type,
req.wait_time,
se.host_name,
se.program_name,
se.last_request_start_time,
se.last_request_end_time,
st.text as [Parent Query],
SUBSTRING(st.text, (req.statement_start_offset/2)+1,
((CASE req.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE req.statement_end_offset
END - req.statement_start_offset)/2) + 1) AS statement_text,
execPlan.query_plan
from sys.dm_exec_sessions se
inner Join sys.dm_exec_connections con on se.session_id=con.session_id and se.is_user_process = 1
Left join sys.dm_exec_requests req on req.session_id = se.session_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(req.plan_handle) as execPlan
order by req.cpu_time DESC
GO




-- Blocking Header
SELECT db_name(er.database_id) as [DB],
er.session_id,
es.original_login_name,
es.client_interface_name,
er.start_time,
er.status,
er.wait_type,
er.wait_resource,
st.text as [Parent Query],
SUBSTRING(st.text, (er.statement_start_offset/2)+1,
((CASE er.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE er.statement_end_offset
END - er.statement_start_offset)/2) + 1) AS statement_text,
er.*
FROM SYS.dm_exec_requests er
join sys.dm_exec_sessions es on (er.session_id = es.session_id)
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
where er.session_id in
(SELECT distinct(blocking_session_id) FROM SYS.dm_exec_requests WHERE blocking_session_id > 0) and blocking_session_id = 0
GO



-- 1.查連線
-- 同一個用戶端開啟多少connection，Group by Client IP
set transaction isolation level read uncommitted

select [client_net_address], COUNT(*) as [Connection Count] from sys.dm_exec_connections
group by [client_net_address]
having COUNT(*) > 1
order by [Connection Count] DESC


-- 特定用戶端IP，所開啟的session狀態
set transaction isolation level read uncommitted

select 
se.session_id, 
se.status,
se.host_name,
con.connect_time,
se.login_time,
se.login_name,
se.program_name,
se.last_request_start_time,
se.last_request_end_time
from sys.dm_exec_sessions se
inner Join sys.dm_exec_connections con on se.session_id=con.session_id and se.is_user_process = 1
where con.[client_net_address] = '192.168.20.110'
order by con.connect_time


-- 2.查requests
-- CPU Usage High
-- status = running and cpu_time increase
--
--大量reqesut的Wait_type = SOS_SCHEDULER_YIELD
-- SOS_SCHEDULER_YIELD represents a SQLOS worker (thread) that has yielded the CPU, presumably to another worker.
-- Task有worker
--
--或
--大量reqesut的Status = RUNNABLE





-- version 5
-- 有IP Address, login_nanme
-- 有open_tran(sleeping session with open_tran) ，此版修改JOIN sys.sysprocesses on條件，讓平行計畫也只出現一筆
-- join sys.dm_os_tasks 判斷平行處理

set transaction isolation level read uncommitted

SELECT se.session_id,
req.cpu_time,
req.status,
se.[program_name],
se.[host_name],
req.start_time,
DATEDIFF(SECOND, req.start_time, GETDATE()) as [duration (sec)],
req.blocking_session_id,
CASE WHEN task.session_id is not null then 'Y'
WHEN task.session_id is null then 'N' END as [Parallel Query],
req.wait_type,
con.client_net_address,
se.[status] as [session_status],
req.command,
se.[login_name], 
DB_NAME(req.database_id) as [DB_in_reqeust],
ISNULL(sysp.open_tran, 0) as [open_tran_in_sysprocess],
req.open_transaction_count as [open_tran_in_request],
sqltext.text as [Parent Query],
SUBSTRING(sqltext.text, req.statement_start_offset / 2, (CASE
    WHEN req.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), sqltext.text)) * 2
    ELSE req.statement_end_offset
  END - req.statement_start_offset) / 2) as  [Individual Query]
from sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
right join sys.dm_exec_sessions se on req.session_id = se.session_id 
left join sys.dm_exec_connections con on con.session_id= se.session_id
LEFT OUTER JOIN sys.sysprocesses sysp on sysp.open_tran > 0 and  sysp.spid = se.session_id
LEFT OUTER JOIN 
(
		SELECT  t.session_id
		FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address       
		WHERE   t.session_id > 50 
		GROUP BY   t.session_id
		HAVING COUNT(*) > 1
) task on req.session_id = task.session_id
where se.is_user_process = 1
and se.session_id <> @@SPID
--and sqltext.text  like '%client_sn int%'
--and sqltext.text  like '%top 10%'
--and se.[host_name]='BD-RD-014'
--and se.program_name like '%Navicat Premium%'
order by req.cpu_time DESC, sysp.open_tran DESC
GO



-- 所有task的狀態，若是多筆則是平行處理，檢查wait type
SELECT  
	--t.task_address,
        t.session_id ,
        t.task_state ,
        t.exec_context_id ,
        wt.wait_duration_ms ,
        wt.wait_type ,
        wt.blocking_session_id ,
        wt.blocking_exec_context_id ,
        wt.resource_description ,
        t.scheduler_id
FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
WHERE   t.session_id > 50 and t.session_id <> @@SPID
ORDER BY t.session_id,t.exec_context_id,wt.blocking_exec_context_id;
GO



-- 正在執行中request，正在使用哪個DB的交易紀錄檔與使用多少交易紀錄檔
SELECT 
Case database_transaction_state When  1 then '交易未初始化'
When  3 then '交易已初始化，但未產生任何記錄'
When  4 then '交易已產生記錄'
When 5 then '已準備交易'
When  10 then '已認可交易'
When  11 then '已回復交易'
When  12 then '正在認可交易' end as [DB_Tran_State],
	
	tdt.database_transaction_log_bytes_reserved,tst.session_id,
    t.[text], [statement] = COALESCE(NULLIF(
         SUBSTRING(
           t.[text],
           r.statement_start_offset / 2,
           CASE WHEN r.statement_end_offset < r.statement_start_offset
             THEN 0
             ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
         ), ''
       ), t.[text])
     FROM sys.dm_tran_database_transactions AS tdt
     INNER JOIN sys.dm_tran_session_transactions AS tst
     ON tdt.transaction_id = tst.transaction_id
         LEFT OUTER JOIN sys.dm_exec_requests AS r
         ON tst.session_id = r.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
     WHERE tdt.database_id = 2;

-- kill
kill xx  WITH STATUSONLY


--SELECT * FROM msdb.dbo.sysjobs
--WHERE job_id = CONVERT(uniqueidentifier, 0x2E7E13DFF42C404E9AE55BDBDB5334F9) ; 








-- version 4
-- 有IP Address, login_nanme
-- 有open_tran(sleeping session with open_tran) ，此版修改JOIN sys.sysprocesses on條件，讓平行計畫也只出現一筆
SELECT se.session_id,
req.blocking_session_id,
req.status,req.wait_type,
se.[program_name],se.[host_name],con.client_net_address,
se.[status] as [session_status],
req.cpu_time,
req.start_time,
req.command,
se.[login_name], 
DB_NAME(req.database_id) as [DB_in_reqeust],
ISNULL(sysp.open_tran, 0) as [open_tran_in_sysprocess],
req.open_transaction_count as [open_tran_in_request],
sqltext.text as [Parent Query],
SUBSTRING(sqltext.text, req.statement_start_offset / 2, (CASE
    WHEN req.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), sqltext.text)) * 2
    ELSE req.statement_end_offset
  END - req.statement_start_offset) / 2) as  [Individual Query]
from sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
right join sys.dm_exec_sessions se on req.session_id = se.session_id
left join sys.dm_exec_connections con on con.session_id= se.session_id
LEFT OUTER JOIN sys.sysprocesses sysp on sysp.open_tran > 0 and  sysp.spid = se.session_id
where se.is_user_process = 1
--and se.[host_name]='BD-RD-014'
order by req.cpu_time DESC, sysp.open_tran DESC
GO

-- 所有task的狀態，若是多筆則是平行處理，檢查wait type
SELECT  
	--t.task_address,
        t.session_id ,
        t.task_state ,
        t.exec_context_id ,
        wt.wait_duration_ms ,
        wt.wait_type ,
        wt.blocking_session_id ,
        wt.blocking_exec_context_id ,
        wt.resource_description ,
        t.scheduler_id
FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
WHERE   t.session_id > 50 and t.session_id <> @@SPID
ORDER BY t.session_id,t.exec_context_id,wt.blocking_exec_context_id;
GO














-- version 3, 加入oepn_tran (sleeping session with open_tran)
-- 因為JOIN了sys.sysprocesses所以平行處理會看到多筆
SELECT se.session_id,
req.blocking_session_id,
req.status,req.wait_type,
se.[program_name],se.[host_name],con.client_net_address,
se.[status] as [session_status],
req.cpu_time,
req.start_time,
req.command,
se.[login_name], 
DB_NAME(req.database_id) as [DB_in_reqeust],
ISNULL(sysp.open_tran, 0) as [open_tran_in_sysprocess],
req.open_transaction_count as [open_tran_in_request],
sqltext.text as [Parent Query],
SUBSTRING(sqltext.text, req.statement_start_offset / 2, (CASE
    WHEN req.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), sqltext.text)) * 2
    ELSE req.statement_end_offset
  END - req.statement_start_offset) / 2) as  [Individual Query]
from sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
right join sys.dm_exec_sessions se on req.session_id = se.session_id
left join sys.dm_exec_connections con on con.session_id= se.session_id
LEFT OUTER JOIN sys.sysprocesses sysp on sysp.spid = se.session_id
where se.is_user_process = 1
--and se.[host_name]='BD-RD-014'
order by req.cpu_time DESC, sysp.open_tran DESC
GO

-- 所有task的狀態，若是多筆則是平行處理，檢查wait type
SELECT  
	--t.task_address,
        t.session_id ,
        t.task_state ,
        t.exec_context_id ,
        wt.wait_duration_ms ,
        wt.wait_type ,
        wt.blocking_session_id ,
        wt.blocking_exec_context_id ,
        wt.resource_description ,
        t.scheduler_id
FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
WHERE   t.session_id > 50 and t.session_id <> @@SPID
ORDER BY t.session_id,t.exec_context_id,wt.blocking_exec_context_id;
GO








-- version 2, 加入IP Address, login_nanme
SELECT se.session_id,
se.[program_name],se.[host_name],con.client_net_address,
se.[status] as [session_status],
se.[login_name], DB_NAME(req.database_id),
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
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
right join sys.dm_exec_sessions se on req.session_id = se.session_id
left join sys.dm_exec_connections con on con.session_id= se.session_id
where se.is_user_process = 1
order by req.cpu_time DESC
GO


-- version 1
-- 平行處理只會看到一筆
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




-- 如過上面的查詢有看到很多筆同樣的session並且wait_type=CXPACKET

-- 平行處理 並且可以看到其他worker正在等待其他資源(例如pageiolatch, latch...等)
-- wait_type=CXPACKET的session_id=76

DECLARE @session_id INT = 76;

SELECT  t.task_address,
        t.task_state ,
        t.session_id ,
        t.exec_context_id ,
        wt.wait_duration_ms ,
        wt.wait_type ,
        wt.blocking_session_id ,
        wt.blocking_exec_context_id ,
        wt.resource_description ,
        t.scheduler_id
FROM    sys.dm_os_tasks t
        LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
WHERE   t.session_id = @session_id
ORDER BY t.exec_context_id,wt.blocking_exec_context_id;


-- demo 平行處理in DEV3 並且也可以看到其他worker正在等待pageiolatch與latch
--SELECT count(*)
--	            FROM dbo.rec_contact WITH (NOLOCK)
--	            WHERE 
--					--agent=0 
--				    --AND 
--				    next_date > '2015-06-01 00:00:00.000'
--				    AND next_time=6 






-- 如過program_name是JOB
-- 找出JOB Name

-- sys.dm_exec_sessions.[program_name]
-- SQLAgent - TSQL JobStep (Job 0x2E7E13DFF42C404E9AE55BDBDB5334F9 : Step 1)
-- SQLAgent - TSQL JobStep (Job 0x19C5179B8BCFA04AAFD47CF90E2C494D : Step 1)
-- SQLAgent - TSQL JobStep (Job 0xC11A5EBD597C8B4ABBA7CDB42E10E950 : Step 1)

--SELECT * FROM msdb.dbo.sysjobs
--WHERE job_id = CONVERT(uniqueidentifier, 0x2E7E13DFF42C404E9AE55BDBDB5334F9) ; 




-- SQL Server 2008 R2 Activity Monitor - process query
SELECT 
   [Session ID]    = s.session_id, 
   [User Process]  = CONVERT(CHAR(1), s.is_user_process),
   [Login]         = s.login_name,   
   [Database]      = ISNULL(db_name(p.dbid), N''), 
   [Task State]    = ISNULL(t.task_state, N''), 
   [Command]       = ISNULL(r.command, N''), 
   [Application]   = ISNULL(s.program_name, N''), 
   [Wait Time (ms)]     = ISNULL(w.wait_duration_ms, 0),
   [Wait Type]     = ISNULL(w.wait_type, N''),
   [Wait Resource] = ISNULL(w.resource_description, N''), 
   [Blocked By]    = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   [Head Blocker]  = 
        CASE 
            -- session has an active request, is blocked, but is blocking others or session is idle but has an open tran and is blocking others
            WHEN r2.session_id IS NOT NULL AND (r.blocking_session_id = 0 OR r.session_id IS NULL) THEN '1' 
            -- session is either not blocking someone, or is blocking someone but is blocked by another party
            ELSE ''
        END, 
   [Total CPU (ms)] = s.cpu_time, 
   [Total Physical I/O (MB)]   = (s.reads + s.writes) * 8 / 1024, 
   [Memory Use (KB)]  = s.memory_usage * 8192 / 1024, 
   [Open Transactions] = ISNULL(r.open_transaction_count,0), 
   [Login Time]    = s.login_time, 
   [Last Request Start Time] = s.last_request_start_time,
   [Host Name]     = ISNULL(s.host_name, N''),
   [Net Address]   = ISNULL(c.client_net_address, N''), 
   [Execution Context ID] = ISNULL(t.exec_context_id, 0),
   [Request ID] = ISNULL(r.request_id, 0),
   [Workload Group] = ISNULL(g.name, N'')
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- In some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as 
    -- waiting for several different threads.  This will cause that thread to show up in multiple rows 
    -- in our grid, which we don't want.  Use ROW_NUMBER to select the longest wait for each thread, 
    -- and use it as representative of the other wait relationships this thread is involved in. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (s.session_id = r2.blocking_session_id)
LEFT OUTER JOIN sys.dm_resource_governor_workload_groups g ON (g.group_id = s.group_id)
LEFT OUTER JOIN sys.sysprocesses p ON (s.session_id = p.spid)
ORDER BY s.session_id;
