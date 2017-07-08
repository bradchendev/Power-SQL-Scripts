-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Replace Cursor with while loop 用While Loop來取代Cursor
-- WHILE (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/while-transact-sql
-- =============================================


DECLARE @DBname sysname;
DECLARE @sqlcmd nvarchar(2000);
DECLARE @RowID INT = 1, @MaxRowID INT;

CREATE TABLE #DB (  RowID int, name sysname );
CREATE TABLE #DBUser (  db sysname, UserName sysname );

INSERT INTO #DB ( RowID,name)
SELECT ROW_NUMBER() 
        OVER (ORDER BY name) AS Row, name
FROM sys.databases where [state] =0 and name not in ('master','tempdb','msdb','model');

SELECT @MaxRowID = MAX(RowID) FROM #DB
WHILE @RowID <= @MaxRowID
BEGIN
	select @DBname = name from #DB where RowID = @RowID
	--PRINT @DBname
	set @sqlcmd = 
	'use [' + @DBname + '];
	insert into #DBUser
	select db_name(),name from sys.database_principals where type = ''S'' and principal_id > 4 and name not like ''#%''
	'
	EXEC(@sqlcmd)
    SET @RowID = @RowID + 1;
END

DROP TABLE #DB;

select * from #DBUser
order by db, UserName

DROP TABLE #DBUser;

