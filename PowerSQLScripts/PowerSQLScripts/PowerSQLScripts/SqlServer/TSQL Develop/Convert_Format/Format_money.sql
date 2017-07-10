-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	Format Money
-- =============================================

SELECT CONVERT(varchar, CAST(987654321 AS money), 1)
-- 987,654,321.00

SELECT REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,987654321),1), '.00','')
-- 987,654,321

SELECT LEFT(CONVERT(VARCHAR, CAST(987654321 AS MONEY), 1),
                   LEN(CONVERT(VARCHAR, CAST(987654321 AS MONEY), 1)) - 3)
-- 987,654,321 