-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	搜尋資料庫物件Search Database Objects

-- =============================================

---- search a SP
--DECLARE @sqlcmd nvarchar(1000)
--DECLARE @searchName nvarchar(50)

--SET @searchName = 'uspGetManagers'
--set @sqlcmd = 
--'
--use [?];
--IF EXISTS (select DB_NAME() ,* from sys.procedures where name like ''%' + @searchName + '%'')
--select DB_NAME(),* from sys.procedures where name like ''%' + @searchName + '%''
--';

--exec sp_MSForEachDb @sqlcmd;


-- search a object
DECLARE @sqlcmd nvarchar(1000)
DECLARE @searchName nvarchar(50)

SET @searchName = 'uspGetManagers'
set @sqlcmd = 
'
use [?];
IF EXISTS (select DB_NAME() ,* from sys.objects where name like ''%' + @searchName + '%'')
select DB_NAME(),* from sys.objects where name like ''%' + @searchName + '%''
';
--PRINT @sqlcmd
exec sp_MSForEachDb @sqlcmd;