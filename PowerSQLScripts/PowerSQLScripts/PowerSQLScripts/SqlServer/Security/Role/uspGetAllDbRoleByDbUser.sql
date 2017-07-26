-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/26
-- Description:	SP for List All Db Role by Db User
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- EXEC [dbo].[uspGetAllDbRoleByDbUser] @DBUser = 'CONTOSO\bradchen'

CREATE PROCEDURE [dbo].[uspGetAllDbRoleByDbUser]
@DBUser sysname
AS
DECLARE @_DBUser sysname;
DECLARE @DBname sysname;
DECLARE @sqlcmd nvarchar(2000);
DECLARE @RowID INT = 1, @MaxRowID INT;

SET @_DBUser = @DBUser

CREATE TABLE #DB (RowID int, name sysname );
--CREATE TABLE #DBRoleMember (db sysname, dbrole sysname, dbUser sysname );
CREATE TABLE #DBRoleMember (db sysname, dbrole sysname);

INSERT INTO #DB (RowID, name)
SELECT ROW_NUMBER() 
        OVER (ORDER BY name) AS Row, name
FROM sys.databases where [state] =0 and name not in ('master','tempdb','msdb','model');

SELECT @MaxRowID = MAX(RowID) FROM #DB
WHILE @RowID <= @MaxRowID
BEGIN
	select @DBname = name from #DB where RowID = @RowID
	/** PRINT @DBname **/
	/** set @sqlcmd = 
	'use [' + @DBname + '];
	insert into #DBRoleMember
	SELECT 
		db_name(),
		DP1.name AS DatabaseRoleName,   
		isnull (DP2.name, ''No members'') AS DatabaseUserName   
	FROM sys.database_role_members AS DRM  
	RIGHT OUTER JOIN sys.database_principals AS DP1  
	ON DRM.role_principal_id = DP1.principal_id  
	LEFT OUTER JOIN sys.database_principals AS DP2  
	ON DRM.member_principal_id = DP2.principal_id  
	WHERE DP1.type = ''R'' and DP2.name = '''+ @_DBUser +'''
	ORDER BY DP1.name;' **/


	set @sqlcmd = 
	'use [' + @DBname + ']
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
    SET @RowID = @RowID + 1;
END

DROP TABLE #DB;

select * from #DBRoleMember
order by db, dbrole

DROP TABLE #DBRoleMember;

GO


