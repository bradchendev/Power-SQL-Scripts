-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Worker Threads

-- =============================================




--Configure the max worker threads Server Configuration Option
--https://msdn.microsoft.com/en-us/library/ms190219.aspx

-- 設定
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE ;  
GO  
--EXEC sp_configure 'max worker threads', 900 ;  
--GO  
--RECONFIGURE;  
--GO  
  
--Number of CPUs	32-bit computer	64-bit computer
--<= 4 processors	256	512
--8 processors	288	576
--16 processors	352	704
--32 processors	480	960
--64 processors	736	1472
--128 processors	4224	4480
--256 processors	8320	8576


-- max worker threads 伺服器組態選項不會將所有系統工作 (例如可用性群組、Service Broker、鎖定管理員與其他工作) 需要的執行緒納入考量。
-- 如果超過設定的執行緒數目，下列查詢會提供已產生其他執行緒之系統工作的相關資訊。


-- 除了User Session使用的worker threads之外，其他執行緒之系統工作耗用的worker threads
SELECT  
s.session_id,  
r.command,  
r.status,  
r.wait_type,  
r.scheduler_id,  
w.worker_address,  
w.is_preemptive,  
w.state,  
t.task_state,  
t.session_id,  
t.exec_context_id,  
t.request_id  
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_exec_requests AS r  
    ON s.session_id = r.session_id  
INNER JOIN sys.dm_os_tasks AS t  
    ON r.task_address = t.task_address  
INNER JOIN sys.dm_os_workers AS w  
    ON t.worker_address = w.worker_address  
WHERE s.is_user_process = 0;  




-- 目前設定決定的worker threads最大數量
--sys.dm_os_sys_info (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms175048.aspx

select 
--sqlserver_start_time,
--affinity_type_desc,
max_workers_count,
stack_size_in_bytes/1024 as [stack_size_in_KB],
cpu_count,
scheduler_count,
--scheduler_total_count,
--hyperthread_ratio,
physical_memory_in_bytes/1024/1024 as [physical_memory_in_MB],
virtual_memory_in_bytes/1024/1024 as [virtual_memory_in_MB],
bpool_committed,bpool_commit_target
from sys.dm_os_sys_info
--sqlserver_start_time	affinity_type_desc	max_workers_count	cpu_count	scheduler_count	scheduler_total_count	hyperthread_ratio	physical_memory_in_bytes	virtual_memory_in_bytes	bpool_committed	bpool_commit_target	stack_size_in_bytes
--2016-09-12 02:07:29.823	AUTO	1408	60	60	73	15	1065038118912	8796092891136	112664576	112664576	2093056



-- worker threads使用量
SELECT 
SUM(current_workers_count) as [Current worker thread] FROM sys.dm_os_schedulers
-- or
select count(*) from sys.dm_os_workers 




-- check cpu and workers
select parent_node_id, scheduler_id,current_tasks_count,
current_workers_count,active_workers_count,work_queue_count    
from sys.dm_os_schedulers    
where status = 'Visible Online'
-- parent_node_id = 實體CPU
-- scheduler_id = 邏輯CPU


select is_preemptive,state,last_wait_type,count(*) as Worker_Count from sys.dm_os_workers    
Group by state,last_wait_type,is_preemptive    
order by count(*) desc

--is_preemptive	state	last_wait_type	Worker_Count
--0	SUSPENDED	MISCELLANEOUS	754
--0	RUNNING	SOS_SCHEDULER_YIELD	24
--0	SUSPENDED	CXPACKET	9
--1	RUNNING	MISCELLANEOUS	5


--sys.dm_os_sys_info (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms175048.aspx
--sys.dm_os_schedulers (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms177526.aspx
--sys.dm_os_tasks (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms174963.aspx
--sys.dm_os_workers (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms178626.aspx
--Max. Worker Threads and when you should change it
--https://blogs.msdn.microsoft.com/sqlsakthi/2011/03/13/max-worker-threads-and-when-you-should-change-it/


