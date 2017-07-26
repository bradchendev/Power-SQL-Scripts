-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/26
-- Description:	SP for List Db Role by Db User
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- EXEC [dbo].[uspGetDbRoleByDbUser] @DB = 'AdventureWorks2008R2' ,@DBUser = 'CONTOSO\bradchen'
CREATE PROCEDURE [dbo].[uspGetDbRoleByDbUser]
@DB sysname,
@DBUser sysname
AS
DECLARE @_DB sysname;
DECLARE @_DBUser sysname;

SET @_DB = @DB;
SET @_DBUser = @DBUser;

DECLARE @sqlcmd nvarchar(2000);

CREATE TABLE #DB (RowID int, name sysname );
CREATE TABLE #DBRoleMember (db sysname, dbrole sysname);

SET @sqlcmd = 
	'use [' + @_DB + ']
	SELECT 
		db_name(),
		DP1.name AS DatabaseRoleName
	FROM sys.database_role_members AS DRM  
	RIGHT OUTER JOIN sys.database_principals AS DP1  
	ON DRM.role_principal_id = DP1.principal_id  
	LEFT OUTER JOIN sys.database_principals AS DP2  
	ON DRM.member_principal_id = DP2.principal_id  
	WHERE DP1.type = ''R'' and DP2.name = '''+ @_DBUser +'''
	ORDER BY DP1.name;'
	
	insert into #DBRoleMember(db , dbrole)
	EXEC(@sqlcmd)

DROP TABLE #DB;
select * from #DBRoleMember
order by db, dbrole

DROP TABLE #DBRoleMember;


GO



