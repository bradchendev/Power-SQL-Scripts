-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/04/xx
-- Description:	Check if Replication enable on this SQL Server Instance

-- =============================================

EXEC sp_MS_replication_installed

-- IF replication installed, then return
-- Command(s) completed successfully.
