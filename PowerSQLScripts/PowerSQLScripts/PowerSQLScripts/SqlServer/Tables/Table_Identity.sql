-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Identity
-- =============================================


CREATE TABLE dbo.Table_Ident4
(
c1 int PRIMARY KEY  IDENTITY(1,1),
c2 varchar(50)
);

INSERT dbo.Table_Ident4(c2) VALUES
('aaa'),('bbb'),('ccc'),('ddd'),('eee'),('fff');

SELECT * FROM dbo.Table_Ident4;

DELETE dbo.Table_Ident4 WHERE c1 > 3;

SELECT * FROM dbo.Table_Ident4;

-- 取得目前最大已使用的Identity值
DBCC CHECKIDENT ( 'dbo.Table_Ident4', NORESEED )
--Checking identity information: current identity value '6', current column value '6'.

-- 將目前已使用最大Identity值為3
-- 下一筆新的INSERT的Identity值就會自動使用4
DBCC CHECKIDENT ( 'dbo.Table_Ident4', RESEED, 3 )
-- Checking identity information: current identity value '6', current column value '3'.

-- 確認目前最大已使用的Identity值已改為3
DBCC CHECKIDENT ( 'dbo.Table_Ident4', NORESEED )
--Checking identity information: current identity value '3', current column value '3'.

INSERT INTO dbo.Table_Ident4 VALUES('ggg')
SELECT * FROM dbo.Table_Ident4;

--drop table dbo.Table_Ident4 

