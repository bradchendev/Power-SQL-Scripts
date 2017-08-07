-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/8/1
-- Description:	SP for List All Db Role by DB name
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- EXEC dbo.uspGetDbRoleByDbName @DB = 'AdventureWorks2008R2', @Sort = 'IsFixedRole', @Order = 'ASC', @Offset = 0, @Limit = 10
-- @Sort = [DbRole], [IsFixedRole], [create_date], [modify_date]

ALTER PROCEDURE [dbo].[uspGetDbRoleByDbName]
@DB sysname,
@Sort varchar(30), -- Sort column name
@Order varchar(5), -- DESC / ASC
@Offset int,
@Limit int
AS
DECLARE @_DB sysname, @_Sort varchar(30), @_Order varchar(5), @_Offset int, @_Limit int

SET @_DB = @DB;
SET @_Sort = @Sort;
SET @_Order = @Order;
SET @_Offset = @Offset + 1;
SET @_Limit = @Limit + @Offset;

DECLARE @sqlcmd nvarchar(2000);

DECLARE @RankOrder nvarchar(254);
SET @RankOrder = '';

if @_Order is not null and @_Sort is not null
BEGIN
	SET @RankOrder = N'ORDER BY [' + @_Sort + '] ' + @_Order
END;


SET @DB = @_DB;
SET @sqlcmd = N'
SELECT * FROM 
(
    SELECT ROW_NUMBER() OVER ( 
    ' + @RankOrder + N'
) AS RankNumber, 
      COUNT(1) OVER () AS TotalCount, 
    * FROM 
    ( 
SELECT 
	[name] as [DbRole], 
	[is_fixed_role] as [IsFixedRole],
	[create_date] as [CreateDate], 
	[modify_date] as [ModifyDate]
FROM [' + @_DB + '].[sys].[database_principals] 
where [type] = ''R'' 
     )
    AS A1
) AS A2
WHERE RankNumber BETWEEN ' + CAST( @_Offset as varchar(20) ) + N' AND ' + CAST( @_Limit as varchar(20) )
	
EXEC(@sqlcmd)


GO




