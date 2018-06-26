-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/6/26
-- Description:	Query Missing Index
-- sys.dm_db_missing_index_details (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-details-transact-sql?view=sql-server-2017
-- =============================================

-- Modify from StoredProcedure [MS_PerfDashboard].[usp_MissingIndexStats] 
	select 
	CAST(gs.avg_user_impact + gs.avg_system_impact as float) as [Overall Impact],
	DB_NAME(d.database_id) as [DB],	
	OBJECT_NAME(d.object_id, d.database_id) as [TableName],
	gs.unique_compiles as [Unique Compiles],
	gs.user_seeks as [User Seeks],
	gs.user_scans as [User Scans],
	gs.avg_total_user_cost as [Avg Total User Cost],
	gs.avg_user_impact as [Avg User Impact],
	N'CREATE INDEX missing_index_' + CAST(d.index_handle AS nvarchar) + N' ON ' + d.statement + N' (' + ISNULL(equality_columns,N'') + 
	CASE WHEN equality_columns is not null and inequality_columns is not null 
	THEN N', '
	ELSE N''
	END
	+ ISNULL(inequality_columns,N'') + N')' +
	CASE WHEN included_columns is not null 
	THEN N' INCLUDE (' + included_columns + N')'
	ELSE N''
	END as [Proposed Index]
	--,d.database_id, d.object_id, d.index_handle, d.equality_columns, d.inequality_columns, d.included_columns, d.statement as fully_qualified_object, gs.* 
	from sys.dm_db_missing_index_groups g 
		join sys.dm_db_missing_index_group_stats gs on gs.group_handle = g.index_group_handle
		join sys.dm_db_missing_index_details d on g.index_handle = d.index_handle
	ORDER By [Overall Impact] DESC
 






-- This stored procedure is in 
--Microsoft® SQL Server 2012 Performance Dashboard Reports
--https://www.microsoft.com/en-us/download/details.aspx?id=29063
-- 
USE [msdb]
GO

/****** Object:  StoredProcedure [MS_PerfDashboard].[usp_MissingIndexStats]    Script Date: 06/26/2018 17:09:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- exec sp_executesql @stmt=N'exec msdb.MS_PerfDashboard.usp_MissingIndexStats @DatabaseID, @ObjectID',@params=N'@DatabaseID NVarChar(max), @ObjectID NVarChar(max)',@DatabaseID=NULL,@ObjectID=NULL
create procedure [MS_PerfDashboard].[usp_MissingIndexStats] @DatabaseID int, @ObjectID int
as
begin
	select d.database_id, d.object_id, d.index_handle, d.equality_columns, d.inequality_columns, d.included_columns, d.statement as fully_qualified_object,
	gs.* 
	from sys.dm_db_missing_index_groups g
		join sys.dm_db_missing_index_group_stats gs on gs.group_handle = g.index_group_handle
		join sys.dm_db_missing_index_details d on g.index_handle = d.index_handle
	where d.database_id = isnull(@DatabaseID , d.database_id) and d.object_id = isnull(@ObjectID, d.object_id)
end

GO


