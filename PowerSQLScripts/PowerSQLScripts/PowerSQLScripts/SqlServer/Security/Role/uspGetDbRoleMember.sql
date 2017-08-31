-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/8/1
-- Modify Date: 2017/8/3
-- Description:	SP for List All Db Role and Member by Db User
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- @Limit 一頁多少筆
-- EXEC [dbo].[uspGetDbRoleMember] @DB = 'AdventureWorks2008R2', @DBRole = 'db_datareader',@Sort = 'DBRole', @Order = 'DESC', @Offset = 0, @Limit = 10
-- EXEC [dbo].[uspGetDbRoleMember] @DB = 'AdventureWorks2008R2', @DBRole = 'db_datareader',@Sort = 'DBRole', @Order = 'DESC', @Offset = 0, @Limit = 10, @Search = 'User1'
-- EXEC [dbo].[uspGetDbRoleMember] @DB = 'AdventureWorks2008R2',  @DBUser= 'CONTOSO', @DBUser= 'bradchen',@Sort = 'DBRole', @Order = 'DESC', @Offset = 0, @Limit = 10

ALTER PROCEDURE [dbo].[uspGetDbRoleMember]
@DB sysname,
@DBRole sysname = null,
@DBUser sysname = null,
@DBUserDomain sysname = null, -- ex. CONTOSO
@Sort varchar(30), -- Sort column name
@Order varchar(5), -- DESC / ASC
@Offset int,
@Limit int,
@Search varchar(50) = null
AS
DECLARE @_DB sysname, @_DBRole sysname, @_DBUser sysname, @_DBUserDomain sysname, 
@_Sort varchar(30), @_Order varchar(5), @_Offset int, @_Limit int, @_Search varchar(50)

SET @_DB = @DB;
SET @_DBRole = @DBRole;
SET @_DBUser = @DBUser;
SET @_DBUserDomain = @DBUserDomain;
SET @_Sort = @Sort;
SET @_Order = @Order;
SET @_Offset = @Offset + 1;
SET @_Limit = @Limit + @Offset;
SET @_Search = @Search;

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

-- WHERE
if @_DBUser is not null
	if @_DBUserDomain is not null
	BEGIN
		SET @Where = @Where + N' AND DRMP.name = ''' + @_DBUserDomain + N'\' + @_DBUser + '''';
	END
	ELSE
	BEGIN
		SET @Where = @Where + N' AND DRMP.name = ''' + @_DBUser + '''';	
	END

if @_DBRole is not null
	SET @Where = @Where + N' AND DRP.name = ''' + @_DBRole + '''';

-- @Search = Member 跟第一個條件一樣
if @_Search is not null
	SET @Where = @Where + N' AND DRMP.name = ''' + @_Search + '''';

SET @sqlcmd = 
N'USE [' + @_DB + N'];
SELECT * FROM 
(
    SELECT ROW_NUMBER() OVER ( 
    ' + @RowNumberOrder + N'
) AS RowNumber, 
      COUNT(1) OVER () AS TotalCount, 
    * FROM 
    ( 
    SELECT  
	    db_name() as DB,
	    DRP.name as DBRole,
	    DRMP.name as Member
    FROM sys.database_role_members AS DRM   
    RIGHT OUTER JOIN sys.database_principals AS DRP
    ON DRM.role_principal_id = DRP.principal_id
    LEFT OUTER JOIN sys.database_principals AS DRMP
    ON DRM.member_principal_id = DRMP.principal_id  
    WHERE  DRP.[type] = ''R'' 
     ' + @Where + N'      
     )
    AS A1
) AS A2
WHERE RowNumber BETWEEN ' + CAST( @_Offset as varchar(20) ) + N' AND ' + CAST( @_Limit as varchar(20) )
	
--PRINT @sqlcmd
EXEC(@sqlcmd)