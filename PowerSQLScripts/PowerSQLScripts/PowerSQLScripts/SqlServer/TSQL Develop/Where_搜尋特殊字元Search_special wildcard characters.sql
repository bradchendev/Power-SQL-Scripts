-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	

--LIKE (Transact-SQL)
--https://docs.microsoft.com/en-us/sql/t-sql/language-elements/like-transact-sql

-- =============================================
--Using Wildcard Characters As Literals
--You can use the wildcard pattern matching characters as literal characters. To use a wildcard character as a literal character, enclose the wildcard character in brackets. The following table shows several examples of using the LIKE keyword and the [ ] wildcard characters.

--Symbol					Meaning
--LIKE '5[%]'			5%
--LIKE '[_]n'				_n
--LIKE '[a-cdf]'			a, b, c, d, or f
--LIKE '[-acdf]'			-, a, c, d, or f
--LIKE '[ [ ]'				[
--LIKE ']'					]
--LIKE 'abc[_]d%'	abc_d and abc_de
--LIKE 'abc[def]'		abcd, abce, and abcf

USE tempdb;  
GO  
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES  
      WHERE TABLE_NAME = 'mytbl2')  
   DROP TABLE mytbl2;  
GO  
USE tempdb;  
GO  
CREATE TABLE mytbl2  
(  
 c1 sysname  
);  
GO  
INSERT mytbl2 VALUES ('Discount is 10-15% off'), ('Discount is .10-.15 off');  
GO  
SELECT c1   
FROM mytbl2  
WHERE c1 LIKE '%10-15!% off%' ESCAPE '!';  
GO
