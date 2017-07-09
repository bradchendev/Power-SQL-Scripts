


-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	比對資料

-- =============================================


-- 找兩邊都有的相同資料
-- INTERSECT查詢出來的筆數與單查詢一個表的資料筆數一樣的話，表示兩個資料相同
SELECT *  FROM [TESTDB1].[dbo].[Table_1]
INTERSECT
select * from [TESTDB1].[dbo].[Table_1_bk]


--  查詢上面有，但下面沒有的資料

--  查詢出來沒有資料的話，表示上面的資料表的資料，下面都有
SELECT *  FROM [TESTDB1].[dbo].[Table_1]
EXCEPT
select * from [TESTDB1].[dbo].[Table_1_bk]

-- 反向查一次，若查詢出來也沒有資料的話，表示上下資料相同
select * from [TESTDB1].[dbo].[Table_1_bk]
EXCEPT
SELECT *  FROM [TESTDB1].[dbo].[Table_1]
