-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	
--Log Shipping Monitoring and Troubleshooting
--交易紀錄傳送監控與疑難排解
--https://blogs.msdn.microsoft.com/bradchen/2016/10/15/log-shipping-monitoring-and-troubleshooting/
-- =============================================





--1.Log Shipping status
-- View the Log Shipping Report (SQL Server Management Studio)
--https://msdn.microsoft.com/en-us/library/ms181149.aspx

--To display the Transaction Log Shipping Status report on a server instance
--1.Connect to a monitor server, primary server, or secondary server.
--2.Right-click the server instance in Object Explorer, point to Reports, and point to Standard Reports.
--3.Click Transaction Log Shipping Status.

--sp_help_log_shipping_monitor (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187820.aspx
--sp_help_log_shipping_monitor

--Remarks
-- sp_help_log_shipping_monitor must be run from the master database on the monitor server.

--Permissions
-- Requires membership in the sysadmin fixed server role.

--找出Monitoring Server方法
SELECT monitor_server FROM msdb.dbo.log_shipping_primary_databases;

--or
SELECT monitor_server FROM msdb.dbo.log_shipping_secondary;

 

--2.Job History

--View the Job History
--https://msdn.microsoft.com/en-us/library/ms181046.aspx

--     To view the job history log
--1.In Object Explorer, connect to an instance of the SQL Server Database Engine, and then expand that instance.
--2.Expand SQL Server Agent, and then expand Jobs.
--3.Right-click a job, and then click View History.
--4.In the Log File Viewer, view the job history.
--5.To update the job history, click Refresh. To view fewer rows, click the Filter button and enter filter parameters.

--or
-- lists all job information for the NightlyBackups job.  
USE msdb ;  
GO  

EXEC dbo.sp_help_jobhistory   
    @job_name = N'LSRestore_ServerName_DBname' ;  
GO

 

--3.Backup and Restore History
-- Backup History and Header Information (SQL Server)
--https://msdn.microsoft.com/en-us/library/ms188653.aspx

--Query SQL Server backup history and restore history records
--https://blogs.msdn.microsoft.com/bradchen/2014/03/12/query-sql-server-backup-history-and-restore-history-records/
 
-- 4.ERRORLOG
-- View the SQL Server Error Log (SQL Server Management Studio)
--https://msdn.microsoft.com/en-us/library/ms187109.aspx
--1.In Object Explorer, connect to an instance of the SQL Server and then expand that instance.
--2.Find and expand the Management section (Assuming you have permissions to see it).
--3.Right-click on SQL Server Logs, select View, and choose View SQL Server Log.


--5.Event log
-- Start Event Viewer
--https://technet.microsoft.com/en-us/library/cc766401(v=ws.11).aspx

--To start Event Viewer by using the Windows interface
--1.Click the Start button.
--2.Click Control Panel .
--3.Click System and Maintenance .
--4.Click Administrative Tools .
--5.Double-click Event Viewer .

--To start Event Viewer by using a command line
--1.Open a command prompt. To open a command prompt, click Start , click All Programs , click Accessories and then click Command Prompt .
--2.Type eventvwr .

--Reference:
-- Monitor Log Shipping (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms190224.aspx


--Stored procedure Description Run this procedure on
--sp_help_log_shipping_monitor_primary Returns monitor records for the specified primary database from the log_shipping_monitor_primary table. Monitor server or primary server 
--sp_help_log_shipping_monitor_secondary Returns monitor records for the specified secondary database from the log_shipping_monitor_secondary table. Monitor server or secondary server 
--sp_help_log_shipping_alert_job Returns the job ID of the alert job. Monitor server, or primary or secondary server if no monitor is defined 
--sp_help_log_shipping_primary_database Retrieves primary database settings and displays the values from the log_shipping_primary_databases and log_shipping_monitor_primary tables. Primary server 
--sp_help_log_shipping_primary_secondary Retrieves secondary database names for a primary database. Primary server 
--sp_help_log_shipping_secondary_database Retrieves secondary-database settings from the log_shipping_secondary, log_shipping_secondary_databases and log_shipping_monitor_secondary tables. Secondary server 
--sp_help_log_shipping_secondary_primary (Transact-SQL) This stored procedure retrieves the settings for a given primary database on the secondary server. Secondary server 

 

--Adding a log shipping monitor
--http://www.sqlservercentral.com/articles/Log+Shipping/77295/
