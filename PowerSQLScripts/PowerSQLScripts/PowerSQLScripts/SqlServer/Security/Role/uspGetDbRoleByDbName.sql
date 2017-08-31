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
-- EXEC dbo.uspGetDbRoleByDbName @DB = 'AdventureWorks2008R2', @Sort = 'IsFixedRole', @Order = 'ASC', @Offset = 0, @Limit = 10, @Search = 'db_dbreader'

-- @Sort = [DbRole], [IsFixedRole], [create_date], [modify_date]

ALTER PROCEDURE [dbo].[uspGetDbRoleByDbName]
@DB sysname,
@Sort varchar(30), -- Sort column name
@Order varchar(5), -- DESC / ASC
@Offset int,
@Limit int,
@Search varchar(50) = null
AS
DECLARE @_DB sysname, @_Sort varchar(30), @_Order varchar(5), @_Offset int, @_Limit int, @_Search varchar(50)

SET @_DB = @DB;
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

if @_Order is not null and @_Sort is not null
BEGIN
	SET @RowNumberOrder = N'ORDER BY [' + @_Sort + '] ' + @_Order
END;

if @_Search is not null
	SET @Where = @Where + N' AND [name] = ''' + @_Search + '''';


SET @DB = @_DB;
SET @sqlcmd = N'
SELECT * FROM 
(
    SELECT ROW_NUMBER() OVER ( 
    ' + @RowNumberOrder + N'
) AS RowNumber, 
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
     ' + @Where + N'      
     )
    AS A1
) AS A2
WHERE RowNumber BETWEEN ' + CAST( @_Offset as varchar(20) ) + N' AND ' + CAST( @_Limit as varchar(20) )
	
EXEC(@sqlcmd)



GO




