-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/5/16
-- Description:	Current Session with open trans
-- =============================================

select DB_NAME(resource_database_id),request_session_id,* 
from sys.dm_tran_locks 
where resource_type = 'DATABASE' 

select * from sys.dm_exec_sessions
where session_id in (84, 81,76)
--dbcc inputbuffer(84)
--kill 84


