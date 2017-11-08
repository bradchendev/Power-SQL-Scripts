-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/10/17
-- Description:	Check Database Mirroring Configuration

-- =============================================

select 
db.name,
dbm.mirroring_state_desc,
dbm.mirroring_role_desc,
dbm.mirroring_safety_level_desc,
dbm.mirroring_witness_state_desc,
dbm.mirroring_failover_lsn,
dbm.mirroring_redo_queue,
dbm.mirroring_redo_queue_type
 from sys.database_mirroring dbm
inner join sys.databases db
on dbm.database_id = db.database_id


-- troubleshooting

-- SQL Server blocking caused by database mirroring wait type DBMIRROR_DBM_EVENT
-- https://blogs.msdn.microsoft.com/grahamk/2011/01/10/sql-server-blocking-caused-by-database-mirroring-wait-type-dbmirror_dbm_event/

select * from msdb.dbo.dbm_monitor_data
where database_id=DB_ID('AdventureWorks2008R2')

-- For example if the send_queue suddenly starts to grow 
-- but the re_do queue doesn't grow, 
-- then it would imply that the the principal cannot send the log records to the mirror so you'd want to look at connectivity maybe, or the service broker queues dealing with the actual transmissions.


