-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/26
-- Description:	SP for List All Db Role Permission by Db Role
-- =============================================


USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- EXEC  [dbo].[uspGetDbRolePermissionByDbRole] @DB = 'AdventureWorks2008R2', @DBRole = 'RD_QA'
CREATE PROCEDURE [dbo].[uspGetDbRolePermissionByDbRole]
@DB sysname, @DBRole sysname
AS
DECLARE @_DB sysname;
DECLARE @_DBRole sysname;
SET @_DBRole = @DBRole;
SET @_DB = @DB;

DECLARE @sqlcmd nvarchar(2000);

SET @sqlcmd = N'
USE [' + @_DB + '];
CREATE TABLE #role_permission
	(
		[Owner] VARCHAR(50)
		, [Object] VARCHAR(128)
		, [Gratee] VARCHAR(50)
		, [Grantor] VARCHAR(50)
		, [ProtectType] VARCHAR(50)
		, [Action] VARCHAR(50)
		, [Column] VARCHAR(128)		
	);
INSERT INTO #role_permission ( [Owner], [Object], [Gratee], [Grantor], [ProtectType],[Action],[Column] )
EXECUTE sp_helprotect NULL, '''+ @_DBRole +''';  

select * from #role_permission '
EXEC(@sqlcmd);

GO


