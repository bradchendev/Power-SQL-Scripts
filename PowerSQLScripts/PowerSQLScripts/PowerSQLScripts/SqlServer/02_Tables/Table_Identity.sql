-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Identity 
-- CREATE TABLE (Transact-SQL) IDENTITY (Property)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql-identity-property
-- @@IDENTITY  (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/identity-transact-sql
-- DBCC CHECKIDENT (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-checkident-transact-sql
-- IDENTITY (Function) (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/identity-function-transact-sql
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






--DBCC CHECKIDENT (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms176057.aspx
--B. Reporting the current identity value
--The following example reports the current identity value in the specified table in the AdventureWorks2012 database, and does not correct the identity value if it is incorrect.
--USE AdventureWorks2012;   
--GO  
--DBCC CHECKIDENT ('Person.AddressType', NORESEED);   
--GO  
  

--C. Forcing the current identity value to a new value
--The following example forces the current identity value in the AddressTypeID column in the AddressType table to a value of 10. Because the table has existing rows, the next row inserted will use 11 as the value, that is, the new current increment value defined for the column value plus 1.
--USE AdventureWorks2012;  
--GO  
--DBCC CHECKIDENT ('Person.AddressType', RESEED, 10);  
--GO  
