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



USE master;  
SELECT sess.session_id, sess.login_name, sess.group_id, grps.name   
FROM sys.dm_exec_sessions AS sess   
JOIN sys.dm_resource_governor_workload_groups AS grps   
    ON sess.group_id = grps.group_id  
WHERE session_id > 50;  
GO



-- _ (Wildcard - Match One Character) (Transact-SQL)
-- https://docs.microsoft.com/zh-tw/sql/t-sql/language-elements/wildcard-match-one-character-transact-sql?view=sql-server-ver15

SELECT name FROM sys.database_principals
WHERE name LIKE 'db[_]%';

--name
---------------
--db_owner
--db_accessadmin
--db_securityadmin
--...

-- [^] (Wildcard - Character(s) Not to Match) (Transact-SQL)
-- https://docs.microsoft.com/zh-tw/sql/t-sql/language-elements/wildcard-character-s-not-to-match-transact-sql?view=sql-server-ver15

-- Uses AdventureWorks  
  
SELECT TOP 5 FirstName, LastName  
FROM Person.Person  
WHERE FirstName LIKE 'Al[^a]%';

SELECT [object_id], OBJECT_NAME(object_id) AS [object_name], name, column_id 
FROM sys.columns 
WHERE name LIKE '[^0-9A-z]%';



