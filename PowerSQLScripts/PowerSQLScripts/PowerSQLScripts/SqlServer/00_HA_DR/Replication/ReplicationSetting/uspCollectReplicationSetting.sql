-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/06/25
-- Description:	Collect Replication Setting from Distribution

-- =============================================



USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspCollectReplicationSetting]    Script Date: 07/05/2018 14:46:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- CREATE By Brad Chen
-- Collect Replication Setting from Distribution 
--
--
-- 1.Create Table for Collection
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSpublications from distribution.dbo.MSpublications where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSarticles from distribution.dbo.MSarticles where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSpublisher_databases from distribution.dbo.MSpublisher_databases where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSsubscriber_info from distribution.dbo.MSsubscriber_info where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSsubscriptions from distribution.dbo.MSsubscriptions where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSdistribution_agents from distribution.dbo.MSdistribution_agents where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSlogreader_agents from distribution.dbo.MSlogreader_agents where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSmerge_agents from distribution.dbo.MSmerge_agents where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSqreader_agents from distribution.dbo.MSqreader_agents where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSrepl_identity_range from distribution.dbo.MSrepl_identity_range where 1=0
--select 1 as [Sn],GETDATE() as [CollectTime],* into DBA.Repl.MSsnapshot_agents from distribution.dbo.MSsnapshot_agents where 1=0
--
-- 2.Set PRIMARY KEY on [Sn] identity(1,1)
--
-- EXEC DBA.dbo.uspCollectReplicationSetting
-- 
ALTER PROCEDURE [dbo].[uspCollectReplicationSetting]
AS
DECLARE @collectTime datetime = GETDATE();


INSERT INTO [DBA].[Repl].[MSarticles]
           ([CollectTime]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication_id]
           ,[article]
           ,[article_id]
           ,[destination_object]
           ,[source_owner]
           ,[source_object]
           ,[description]
           ,[destination_owner])
SELECT @collectTime, * from distribution.dbo.[MSarticles];
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSdistribution_agents]
           ([CollectTime]
           ,[id]
           ,[name]
           ,[publisher_database_id]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication]
           ,[subscriber_id]
           ,[subscriber_db]
           ,[subscription_type]
           ,[local_job]
           ,[job_id]
           ,[subscription_guid]
           ,[profile_id]
           ,[anonymous_subid]
           ,[subscriber_name]
           ,[virtual_agent_id]
           ,[anonymous_agent_id]
           ,[creation_date]
           ,[queue_id]
           ,[queue_status]
           ,[offload_enabled]
           ,[offload_server]
           ,[dts_package_name]
           ,[dts_package_password]
           ,[dts_package_location]
           ,[sid]
           ,[queue_server]
           ,[subscriber_security_mode]
           ,[subscriber_login]
           ,[subscriber_password]
           ,[reset_partial_snapshot_progress]
           ,[job_step_uid]
           ,[subscriptionstreams]
           ,[subscriber_type]
           ,[subscriber_provider]
           ,[subscriber_datasrc]
           ,[subscriber_location]
           ,[subscriber_provider_string]
           ,[subscriber_catalog])
SELECT @collectTime, * from distribution.dbo.[MSdistribution_agents];
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSlogreader_agents]
           ([CollectTime]
           ,[id]
           ,[name]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication]
           ,[local_job]
           ,[job_id]
           ,[profile_id]
           ,[publisher_security_mode]
           ,[publisher_login]
           ,[publisher_password]
           ,[job_step_uid])
SELECT @collectTime, * from distribution.dbo.[MSlogreader_agents];
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSmerge_agents]
           ([CollectTime]
           ,[id]
           ,[name]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication]
           ,[subscriber_id]
           ,[subscriber_db]
           ,[local_job]
           ,[job_id]
           ,[profile_id]
           ,[anonymous_subid]
           ,[subscriber_name]
           ,[creation_date]
           ,[offload_enabled]
           ,[offload_server]
           ,[sid]
           ,[subscriber_security_mode]
           ,[subscriber_login]
           ,[subscriber_password]
           ,[publisher_security_mode]
           ,[publisher_login]
           ,[publisher_password]
           ,[job_step_uid])
SELECT @collectTime, * from distribution.dbo.[MSmerge_agents];
PRINT @@ROWCOUNT


INSERT INTO [DBA].[Repl].[MSpublications]
(
[CollectTime]
      ,[publisher_id]
      ,[publisher_db]
      ,[publication]
      ,[publication_id]
      ,[publication_type]
      ,[thirdparty_flag]
      ,[independent_agent]
      ,[immediate_sync]
      ,[allow_push]
      ,[allow_pull]
      ,[allow_anonymous]
      ,[description]
      ,[vendor_name]
      ,[retention]
      ,[sync_method]
      ,[allow_subscription_copy]
      ,[thirdparty_options]
      ,[allow_queued_tran]
      ,[options]
      ,[retention_period_unit]
      ,[allow_initialize_from_backup]
      ,[min_autonosync_lsn]
)
SELECT @collectTime, * from distribution.dbo.[MSpublications]
PRINT @@ROWCOUNT


INSERT INTO [DBA].[Repl].[MSpublisher_databases]
           ([CollectTime]
           ,[publisher_id]
           ,[publisher_db]
           ,[id]
           ,[publisher_engine_edition])
SELECT @collectTime, * from distribution.dbo.[MSpublisher_databases]
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSqreader_agents]
           ([CollectTime]
           ,[id]
           ,[name]
           ,[job_id]
           ,[profile_id]
           ,[job_step_uid])
SELECT @collectTime, * from distribution.dbo.[MSqreader_agents]
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSrepl_identity_range]
           ([CollectTime]
           ,[publisher]
           ,[publisher_db]
           ,[tablename]
           ,[identity_support]
           ,[next_seed]
           ,[pub_range]
           ,[range]
           ,[max_identity]
           ,[threshold]
           ,[current_max])
SELECT @collectTime, * from distribution.dbo.[MSrepl_identity_range]
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSsnapshot_agents]
           ([CollectTime]
           ,[id]
           ,[name]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication]
           ,[publication_type]
           ,[local_job]
           ,[job_id]
           ,[profile_id]
           ,[dynamic_filter_login]
           ,[dynamic_filter_hostname]
           ,[publisher_security_mode]
           ,[publisher_login]
           ,[publisher_password]
           ,[job_step_uid])
SELECT @collectTime, * from distribution.dbo.[MSsnapshot_agents]
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSsubscriber_info]
           ([CollectTime]
           ,[publisher]
           ,[subscriber]
           ,[type]
           ,[login]
           ,[password]
           ,[description]
           ,[security_mode])
SELECT @collectTime, * from distribution.dbo.[MSsubscriber_info]
PRINT @@ROWCOUNT

INSERT INTO [DBA].[Repl].[MSsubscriptions]
           ([CollectTime]
           ,[publisher_database_id]
           ,[publisher_id]
           ,[publisher_db]
           ,[publication_id]
           ,[article_id]
           ,[subscriber_id]
           ,[subscriber_db]
           ,[subscription_type]
           ,[sync_type]
           ,[status]
           ,[subscription_seqno]
           ,[snapshot_seqno_flag]
           ,[independent_agent]
           ,[subscription_time]
           ,[loopback_detection]
           ,[agent_id]
           ,[update_mode]
           ,[publisher_seqno]
           ,[ss_cplt_seqno]
           ,[nosync_type])
SELECT @collectTime, * from distribution.dbo.[MSsubscriptions]
PRINT @@ROWCOUNT

-- delete	
PRINT 'Delete [DBA].[Repl].[MSarticles] where [CollectTime] < 90 day'
DELETE [DBA].[Repl].[MSarticles]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSdistribution_agents] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSdistribution_agents]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[[MSlogreader_agents] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSlogreader_agents]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSmerge_agents] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSmerge_agents]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSpublications] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSpublications]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSpublisher_databases] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSpublisher_databases]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSqreader_agents] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSqreader_agents]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSrepl_identity_range] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSrepl_identity_range]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSsnapshot_agents] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSsnapshot_agents]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSsubscriber_info] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSsubscriber_info]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

PRINT 'Delete [DBA].[Repl].[MSsubscriptions] where CollectTime < 90 day'	
DELETE [DBA].[Repl].[MSsubscriptions]
WHERE [CollectTime] < CAST(DATEADD(DAY, -90, @collectTime) AS DATE);
PRINT @@ROWCOUNT

GO

