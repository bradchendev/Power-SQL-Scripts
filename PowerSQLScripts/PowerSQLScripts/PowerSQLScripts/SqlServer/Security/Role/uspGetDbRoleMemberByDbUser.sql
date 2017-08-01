-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/8/1
-- Description:	SP for List All Db Role and Member by Db User
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- @Limit 一頁多少筆
-- EXEC [dbo].[uspGetDbRoleByDbUser2] @DB = 'AdventureWorks2008R2' ,@Sort = 'DBRole', @DBUser = 'CONTOSO\bradchen', @Order = 'DESC', @Offset = 0, @Limit = 10
-- EXEC [dbo].[uspGetDbRoleByDbUser2] @DB = 'AdventureWorks2008R2' ,@Sort = 'DBRole', @Order = 'DESC', @Offset = 0, @Limit = 10
-- EXEC [dbo].[uspGetDbRoleByDbUser2] @DB = 'AdventureWorks2008R2' ,@Sort = 'Member', @Order = 'DESC', @Offset = 0, @Limit = 10
-- EXEC [dbo].[uspGetDbRoleByDbUser2] @DB = 'AdventureWorks2008R2' ,@Sort = 'DB', @Order = 'DESC', @Offset = 0, @Limit = 10

ALTER PROCEDURE [dbo].[uspGetDbRoleMemberByDbUser]
@DB sysname,
@DBUser sysname = null,
@Sort varchar(30), -- Sort column name
@Order varchar(5), -- DESC / ASC
@Offset int,
@Limit int
AS
DECLARE @_DB sysname, @_DBUser sysname, @_Sort varchar(30), @_Order varchar(5), @_Offset int, @_Limit int

SET @_DB = @DB;
SET @_DBUser = @DBUser;
SET @_Sort = @Sort;
SET @_Order = @Order;
SET @_Offset = @Offset + 1;
SET @_Limit = @Limit + @Offset;


DECLARE @sqlcmd nvarchar(2000);

DECLARE @RankOrder nvarchar(254);
DECLARE @Where nvarchar(254);
SET @RankOrder = '';
SET @Where = '';

if @_Order is not null and @_Sort is not null
BEGIN
	SET @RankOrder = N'ORDER BY [' + @_Sort + '] ' + @_Order
END;

if @_DBUser is not null
	SET @Where = N' AND DRMP.name = ''' + @_DBUser + '''';


SET @sqlcmd = 
N'USE [' + @_DB + N'];
SELECT * FROM 
(
    SELECT ROW_NUMBER() OVER ( 
    ' + @RankOrder + N'
) AS RankNumber, 
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
WHERE RankNumber BETWEEN ' + CAST( @_Offset as varchar(20) ) + N' AND ' + CAST( @_Limit as varchar(20) )
	
	
-- PRINT @sqlcmd
	EXEC(@sqlcmd)



