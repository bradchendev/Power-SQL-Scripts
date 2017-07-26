-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/26
-- Description:	SP for List All Db Role by DB name
-- =============================================

USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- EXEC dbo.uspGetDbRoleByDbName @DB = 'AdventureWorks2008R2'

CREATE PROCEDURE [dbo].[uspGetDbRoleByDbName]
@DB sysname
AS
DECLARE @DBname sysname;
DECLARE @sqlcmd nvarchar(2000);

SET @DBname = @DB;
SET @sqlcmd = 'SELECT [name], [create_date], [modify_date] from [' + @DBname + '].[sys].[database_principals] where [type] = ''R''';
EXEC(@sqlcmd)

GO


