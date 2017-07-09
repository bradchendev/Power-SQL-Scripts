-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Memory Usage.sql

-- =============================================


SELECT  
(physical_memory_in_use_kb/1024) AS Memory_usedby_Sqlserver_MB,  
(locked_page_allocations_kb/1024) AS Locked_pages_used_Sqlserver_MB,  --如果有值表示啟用Lock pages,則Task Manager上面的sqlservr.exe working set就不準確了
(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,  
process_physical_memory_low,  
process_virtual_memory_low  
FROM sys.dm_os_process_memory; 


/*============================================================================ 
 Script to report Memory usage details of a SQL Server instance 
 Author: Sakthivel Chidambaram, Microsoft http://blogs.msdn.com/b/sqlsakthi 
 https://blogs.msdn.microsoft.com/sqlsakthi/2011/02/28/t-sql-query-script-to-monitor-memory-usage-of-a-sql-server-instance/
 
 Date: June 2012 
 Version: V2 
 
 V1: Initial Release 
 V2: Added PLE, Memory grants pending, Checkpoint, Lazy write,Free list counters 
 
 THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
 ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
 TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A 
 PARTICULAR PURPOSE. 
 
 ============================================================================*/ 
 -- We don't need the row count 
 SET NOCOUNT ON 
 
 -- Get size of SQL Server Page in bytes 
 DECLARE @pg_size INT, @Instancename varchar(50) 
 SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E' 
 
 -- Extract perfmon counters to a temporary table 
 IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters 
 SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters 
 
 -- Get SQL Server instance name 
 SELECT @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name]))) FROM #perfmon_counters WHERE counter_name = 'Buffer cache hit ratio' 
 
 -- Print Memory usage details 
 PRINT '----------------------------------------------------------------------------------------------------' 
 PRINT 'Memory usage details for SQL Server instance ' + @@SERVERNAME + ' (' + CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' + SUBSTRING(@@VERSION, CHARINDEX('X',@@VERSION),4) + ' - ' + CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')' 
 PRINT '----------------------------------------------------------------------------------------------------' 
 SELECT 'Memory visible to the Operating System' 
 SELECT CEILING(physical_memory_in_bytes/1048576.0) as [Physical Memory_MB], CEILING(physical_memory_in_bytes/1073741824.0) as [Physical Memory_GB], CEILING(virtual_memory_in_bytes/1073741824.0) as [Virtual Memory GB] FROM sys.dm_os_sys_info 
 SELECT 'Buffer Pool Usage at the Moment' 
 SELECT (bpool_committed*8)/1024.0 as BPool_Committed_MB, (bpool_commit_target*8)/1024.0 as BPool_Commit_Tgt_MB,(bpool_visible*8)/1024.0 as BPool_Visible_MB FROM sys.dm_os_sys_info 
 SELECT 'Total Memory used by SQL Server Buffer Pool as reported by Perfmon counters' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Total Server Memory (KB)' 
 SELECT 'Memory needed as per current Workload for SQL Server instance' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Target Server Memory (KB)' 
 SELECT 'Total amount of dynamic memory the server is using for maintaining connections' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Connection Memory (KB)' 
 SELECT 'Total amount of dynamic memory the server is using for locks' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Lock Memory (KB)' 
 SELECT 'Total amount of dynamic memory the server is using for the dynamic SQL cache' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'SQL Cache Memory (KB)' 
 SELECT 'Total amount of dynamic memory the server is using for query optimization' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Optimizer Memory (KB) ' 
 SELECT 'Total amount of dynamic memory used for hash, sort and create index operations.' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Granted Workspace Memory (KB) ' 
 SELECT 'Total Amount of memory consumed by cursors' 
 SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM #perfmon_counters WHERE counter_name = 'Cursor memory usage' and instance_name = '_Total' 
 SELECT 'Number of pages in the buffer pool (includes database, free, and stolen).' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name= @Instancename+'Buffer Manager' and counter_name = 'Total pages' 
 SELECT 'Number of Data pages in the buffer pool' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Database pages' 
 SELECT 'Number of Free pages in the buffer pool' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free pages' 
 SELECT 'Number of Reserved pages in the buffer pool' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Reserved pages' 
 SELECT 'Number of Stolen pages in the buffer pool' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Stolen pages' 
 SELECT 'Number of Plan Cache pages in the buffer pool' 
 SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB FROM #perfmon_counters WHERE object_name=@Instancename+'Plan Cache' and counter_name = 'Cache Pages' and instance_name = '_Total' 
 SELECT 'Page Life Expectancy - Number of seconds a page will stay in the buffer pool without references' 
 SELECT cntr_value as [Page Life in seconds],CASE WHEN (cntr_value > 300) THEN 'PLE is Healthy' ELSE 'PLE is not Healthy' END as 'PLE Status' FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Page life expectancy' 
 SELECT 'Number of requests per second that had to wait for a free page' 
 SELECT cntr_value as [Free list stalls/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free list stalls/sec' 
 SELECT 'Number of pages flushed to disk/sec by a checkpoint or other operation that require all dirty pages to be flushed' 
 SELECT cntr_value as [Checkpoint pages/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Checkpoint pages/sec' 
 SELECT 'Number of buffers written per second by the buffer manager"s lazy writer' 
 SELECT cntr_value as [Lazy writes/sec] FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Lazy writes/sec' 
 SELECT 'Total number of processes waiting for a workspace memory grant' 
 SELECT cntr_value as [Memory Grants Pending] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Pending' 
 SELECT 'Total number of processes that have successfully acquired a workspace memory grant' 
 SELECT cntr_value as [Memory Grants Outstanding] FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Outstanding'
 