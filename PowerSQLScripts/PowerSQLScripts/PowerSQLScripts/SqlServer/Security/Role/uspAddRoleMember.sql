

USE [DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Brad Chen
-- Create date:    2017-08-21
-- Description:    增加資料庫角色成員
-- Modified By    Modification Date    Modification Description

-- EXEC  [dbo].[uspAddRoleMember] @Db = 'AdventureWorks2008R2', @DbUser = 'bradchen', @DbUserDomain = 'CONTOSO', @DbRole = 'Confidential', @Action='Add'
-- EXEC  [dbo].[uspAddRoleMember] @Db = 'AdventureWorks2008R2', @DbUser = 'bradchen', @DbUserDomain = 'CONTOSO', @DbRole = 'Confidential', @Action='Drop'

-- =============================================


ALTER PROCEDURE [dbo].[uspAddRoleMember]
@Db sysname,
@DbUser sysname, 
@DbUserDomain sysname = null, -- ex. CONTOSO
@DbRole sysname,
@Action nvarchar(10) -- ex. Add or Drop
AS
BEGIN TRY 
	BEGIN
	SET NOCOUNT ON;  
	DECLARE @SQL nvarchar(500) = N'';
	DECLARE @_Db sysname = @Db;
	DECLARE @_DbUser sysname = @DbUser;
	DECLARE @_DbUserDomain sysname = @DbUserDomain;
	DECLARE @_DbRole sysname = @DbRole;
	DECLARE @_Action nvarchar(10) = @Action;
	
	
		SET @SQL = 
		N'IF Not Exists(select * from sys.server_principals where [name] = '''+@_DbUserDomain + N'\' + @_DBUser + N''' )
			BEGIN 
				CREATE LOGIN ['+@_DbUserDomain + N'\' + @_DBUser +N'] FROM WINDOWS WITH DEFAULT_DATABASE=[master] 
			END;'
		--PRINT @CreateLoginSql
		EXEC(@SQL);
		
		SET @SQL = 
		N'USE [' + @_Db + N']
			IF Not Exists(select * from sys.database_principals where [name] = '''+@_DbUserDomain + N'\' + @_DBUser + N''' )
			BEGIN 
				CREATE USER ['+@_DbUserDomain + N'\' + @_DBUser + N'] FOR LOGIN ['+@_DbUserDomain + N'\' + @_DBUser + N']
			END;'
		--PRINT @CreateDbUserSql
		EXEC(@SQL);
	
	SET @SQL = N'USE [' + @_Db + N'];';
	
	If @_Action = N'Add'
	BEGIN
		SET @SQL = @SQL + N'EXEC sp_addrolemember @rolename = ' + @_DbRole + N', @membername = ''' + @_DbUserDomain + N'\' + @_DBUser +  N''';'
		-- FOR SQL 2012
		--SET @SQL = @SQL + N' ALTER ROLE ' + @_DbRole + N' ADD MEMBER [' + @_DbUserDomain + N'\' + @_DBUser +  N'];'
		
	END
	ELSE
	BEGIN
		if @_Action = N'Drop'
		BEGIN
			SET @SQL = @SQL + N'EXEC sp_droprolemember @rolename = ' + @_DbRole + N', @membername = ''' + @_DbUserDomain + N'\' + @_DBUser +  N''';'		
			-- FOR SQL 2012
			--SET @SQL = @SQL + N' ALTER ROLE ' + @_DbRole + N' DROP MEMBER [' + @_DbUserDomain + N'\' + @_DBUser +  N'];'	
		END
	END
	
	--PRINT @SQL
	EXEC(@SQL);
	
	END 
END TRY 
BEGIN CATCH
	EXEC dbo.uspRaiseError;
END CATCH

