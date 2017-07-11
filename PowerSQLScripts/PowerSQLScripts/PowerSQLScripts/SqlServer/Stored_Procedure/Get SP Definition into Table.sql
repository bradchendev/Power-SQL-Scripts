-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	將SP的內容寫到資料表

-- =============================================


-- multi-Line (SP的內容寫成多筆資料)

--CREATE TABLE ##SP_Def 
--(testData nvarchar(1000)
--)

DECLARE @SQL nvarchar(max)
TRUNCATE TABLE ##SP_Def; 

SET @SQL = '
INSERT INTO ##SP_Def 
EXEC sp_helptext ''dbo.usp5'''

--PRINT @SQL
EXEC(@SQL)
SELECT * FROM ##SP_Def;

DROP TABLE ##SP_Def







-- Single line (SP的內容寫成一筆資料)
DECLARE @Table TABLE(
    	Val VARCHAR(MAX)
)

INSERT INTO @Table EXEC sp_helptext 'dbo.usp5'

DECLARE @Val VARCHAR(MAX)

SELECT  @Val = COALESCE(@Val + ' ' + Val, Val)
FROM    @Table

SELECT @Val