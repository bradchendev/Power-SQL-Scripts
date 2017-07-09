-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Setup Replication 

-- =============================================

-- 1.Add Distributor and Subscriber
/****** Begin: Script to be run at Publisher ******/
/****** Installing the server as a Distributor. ******/
--use master
--select * from sys.sysservers
--where srvname = 'repl_distributor'

--exec sp_adddistributor @distributor = N'xxxxxx', @password = N''
--GO

-- sp_adddistributor (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms176028.aspx
-- Creates an entry in the sys.sysservers table (if there is not one), marks the server entry as a Distributor, and stores property information. This stored procedure is executed at the Distributor on the master database to register and mark the server as a distributor. In the case of a remote distributor, it is also executed at the Publisher from the master database to register the remote distributor.

-- 若本機散發(發行與散發同一台)，就只在散發者上執行
-- 若使遠端散發，則除了在散發者也要在發行者上執行
--      發行與散發者上的sys.sysserver都會有一筆srvname = 'repl_distributor'



--exec sp_addsubscriber @subscriber = N'xxxxxxx', @type = 0, @description = N''
--GO

--sp_addsubscriber (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188360.aspx
--Adds a new Subscriber to a Publisher, enabling it to receive publications. This stored procedure is executed at the Publisher on the publication database for snapshot and transactional publications; and for merge publications using a remote Distributor, this stored procedure is executed at the Distributor.
--Important
--This stored procedure has been deprecated. You are no longer required to explicitly register a Subscriber at the Publisher.


-- 2.
-- Enabling the replication database
select 
	[name],
	[is_published] 
	from master.sys.databases

use master
exec sp_replicationdboption @dbname = N'AdventureWork2008R2', @optname = N'publish', @value = N'true'
GO

-- create and enable log reader agent
exec [AdventureWork2008R2].sys.sp_addlogreader_agent @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
GO

-- sp_replicationdboption (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms188769.aspx
-- Sets a replication database option for the specified database. This stored procedure is executed at the Publisher or Subscriber on any database.
--Remarks
--sp_replicationdboption is used in snapshot replication, transactional replication, and merge replication.
--This procedure creates or drops specific replication system tables, security accounts, and so on, depending on the options given. Sets the corresponding category bit in the master.sysdatabases system table and creates the necessary system tables.
--To disable publishing, the publication database must be online. If a database snapshot exists for the publication database, it must be dropped before disabling publishing. A database snapshot is a read-only offline copy of a database, and is not related to a replication snapshot. For more information, see Database Snapshots (SQL Server).




-- 調整agent profile






-- 新增Publication與subscription

	









-- 移除訂閱與發行集
-- Run script at Publisher

---- Dropping the transactional subscriptions
--use [AdventureWorks2008R2]
--exec sp_dropsubscription @publication = N'Tpub1', 
--@subscriber = N'SubSQL1', @destination_db = N'AdventureWorks2008R2', @article = N'all'
--GO


---- Dropping the transactional articles
--use [AdventureWorks2008R2]
--exec sp_dropsubscription @publication = N'Tpub1', 
--@article = N'Address', @subscriber = N'all', @destination_db = N'all'
--GO
--use [AdventureWorks2008R2]
--exec sp_droparticle @publication = N'Tpub1', 
--@article = N'Address', @force_invalidate_snapshot = 1
--GO

---- Dropping the transactional publication
--use [AdventureWorks2008R2]
--exec sp_droppublication @publication = N'Tpub1'
--GO


