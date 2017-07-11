-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	 Performance Counter
-- sys.dm_os_performance_counters (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql

-- =============================================


SELECT [object_name], [counter_name],  
   [instance_name], [cntr_value] 
FROM sys.[dm_os_performance_counters] 
WHERE [object_name] = 'SQLServer:Buffer Manager';

SELECT DISTINCT [object_name]  
FROM sys.[dm_os_performance_counters]  
ORDER BY [object_name];





select * from sys.dm_os_performance_counters
where 
(
object_name = 'SQLServer:Access Methods'
and counter_name in ('Workfiles Created/sec','Worktables Created/sec', 'Worktables From Cache Ratio')
)
or
(
object_name = 'SQLServer:General Statistics'
and counter_name in ('Temp Tables Creation Rate', 'Temp Tables For Destruction')
);

--sys.dm_os_performance_counters (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187743.aspx
--Interpreting the counter values from sys.dm_os_performance_counters
--https://blogs.msdn.microsoft.com/psssql/2013/09/23/interpreting-the-counter-values-from-sys-dm_os_performance_counters/

