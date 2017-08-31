

USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Brad Chen
-- Create date:    2017-08-22
-- Description:    增加資料庫角色權限
-- Modified By    Modification Date    Modification Description

 --EXEC [dbo].[uspAddRolePermission] 
	--@Db = N'AdventureWorks2008R2', @ObjectTypeName = N'table', @ObjectOwnerName = N'dbo', 
	--@ObjectName = N'Address', @Grantee = N'PG_Role1', @ProtectType = N'grant',
	--@Action = N'select,update,insert'

 --EXEC [dbo].[uspAddRolePermission] 
	--@Db = N'AdventureWorks2008R2', @ObjectTypeName = N'procedure', @ObjectOwnerName = N'dbo', 
	--@ObjectName = N'uspGetOrder', @Grantee = N'PG_Role1', @ProtectType = N'grant',
	--@Action = N'execute'

-- =============================================
CREATE PROCEDURE [dbo].[uspAddRolePermission]
@Db sysname,
@ObjectTypeName nvarchar(30), -- ex. table, procedure
@ObjectOwnerName nvarchar(30), -- ex. dbo
@ObjectName nvarchar(50), -- ex. Address
@Grantee nvarchar(50), -- ex. MyRole1
@ProtectType nvarchar(30), -- ex. grant
@Action nvarchar(30) -- ex. select or select,update,insert
AS
BEGIN TRY 
	BEGIN
	SET NOCOUNT ON;  
	DECLARE @SQL nvarchar(1000) = N'';
	DECLARE @_Db sysname = @Db;
	DECLARE @_ObjectTypeName nvarchar(30) = @ObjectTypeName;
	DECLARE @_ObjectOwnerName nvarchar(30) = @ObjectOwnerName;
	DECLARE @_ObjectName nvarchar(50) = @ObjectName;
	DECLARE @_Grantee nvarchar(50) = @Grantee;
	DECLARE @_ProtectType nvarchar(30) = @ProtectType;
	DECLARE @_Action nvarchar(30) = @Action;

	
	SET @SQL = N'USE [' + @Db + N'];';
	
	--If @_ObjectTypeName = N'table'
	--BEGIN
	--	SET @SQL = @SQL + @_ProtectType + N' ' + @_Action + N' ON OBJECT::' + @_ObjectOwnerName + N'.' + @_ObjectName +  N' TO [' + @Grantee + N'];'
	--END
	--ELSE
	--BEGIN
	--	If @_ObjectTypeName = N'procedure'
	--	BEGIN
	--		SET @SQL = @SQL + @_ProtectType + N' ' + @_Action + N' ON OBJECT::' + @_ObjectOwnerName + N'.' + @_ObjectName +  N' TO [' + @Grantee + N'];'			
	--	END
	--END

	SET @SQL = @SQL + @_ProtectType + N' ' + @_Action + N' ON OBJECT::' + @_ObjectOwnerName + N'.' + @_ObjectName +  N' TO [' + @Grantee + N'];'			

	--PRINT @SQL
	EXEC(@SQL);
	
	END 
END TRY 
BEGIN CATCH
	EXEC dbo.uspRaiseError;
END CATCH


GO


