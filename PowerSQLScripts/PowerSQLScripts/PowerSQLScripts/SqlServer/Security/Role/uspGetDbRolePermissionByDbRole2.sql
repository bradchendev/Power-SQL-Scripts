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

-- EXEC  [dbo].[uspGetDbRolePermissionByDbRole] @DB = 'AdventureWorks2008R2', @DBRole = 'RD_QA',@Sort = 'Object', @Order = 'DESC', @Offset = 0, @Limit = 10
-- EXEC  [dbo].[uspGetDbRolePermissionByDbRole] @DB = 'AdventureWorks2008R2', @DBRole = 'RD_QA',@Sort = 'Object', @Order = 'DESC', @Offset = 0, @Limit = 10, @Search = 'Table_1'

ALTER PROCEDURE [dbo].[uspGetDbRolePermissionByDbRole]
@DB sysname, 
@DBRole sysname,
@Sort varchar(30), -- Sort column name
@Order varchar(5), -- DESC / ASC
@Offset int,
@Limit int,
@Search varchar(50) = null
AS
DECLARE @_DB sysname, @_DBRole sysname;
DECLARE @_Sort varchar(30), @_Order varchar(5), @_Offset int, @_Limit int, @_Search varchar(50)

SET @_DBRole = @DBRole;
SET @_DB = @DB;
SET @_Sort = @Sort;
SET @_Order = @Order;
SET @_Offset = @Offset + 1;
SET @_Limit = @Limit + @Offset;
SET @_Search = @Search;

if @_DB not in ('master','msdb', 'model','tempdb')
begin
 
	DECLARE @sqlcmd nvarchar(2000);

	DECLARE @RowNumberOrder nvarchar(254);
	DECLARE @Where nvarchar(254);
	SET @RowNumberOrder = '';
	SET @Where = '';

	-- ROW_NUMBER() OVER ( ORDER BY ...
	if @_Order is not null and @_Sort is not null
	BEGIN
		SET @RowNumberOrder = N'ORDER BY [' + @_Sort + '] ' + @_Order
	END;

	-- WHERE @Search= a DB Object
	if @_Search is not null
		SET @Where = @Where + N' AND [Object] = ''' + @_Search + '''';


	SET @sqlcmd = N'
	USE [' + @_DB + '];
	CREATE TABLE #role_permission
		(
			[Owner] VARCHAR(50)
			, [Object] VARCHAR(128)
			, [Grantee] VARCHAR(50)
			, [Grantor] VARCHAR(50)
			, [ProtectType] VARCHAR(50)
			, [Action] VARCHAR(50)
			, [Column] VARCHAR(128)		
		);
	INSERT INTO #role_permission ( [Owner], [Object], [Grantee], [Grantor], [ProtectType],[Action],[Column] )
	EXECUTE sp_helprotect NULL, '''+ @_DBRole + N''';  

	SELECT * FROM 
	(
		SELECT ROW_NUMBER() OVER ( 
		' + @RowNumberOrder + N'
	) AS RowNumber, 
		  COUNT(1) OVER () AS TotalCount, 
		* FROM 
		( 
		SELECT  
			[Owner], [Object], [Grantee], [Grantor], [ProtectType],[Action],[Column] 
		FROM #role_permission 
		WHERE  1 = 1 
		 ' + @Where + N'      
		 )
		AS A1
	) AS A2
	WHERE RowNumber BETWEEN ' + CAST( @_Offset as varchar(20) ) + N' AND ' + CAST( @_Limit as varchar(20) ) + N';'

	EXEC(@sqlcmd);

end

GO


