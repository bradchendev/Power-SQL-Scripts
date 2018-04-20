-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/4/19
-- Description:	刪除重複資料

-- =============================================

-- identify which rows have duplicate primary key values:
-- sample 1
--create table Employee2(Id int, name varchar(20), age int, sex varchar(1));

--insert into Employee2(Id, name, age, sex) values(1,'brad', 38, 'M');
--insert into Employee2(Id, name, age, sex) values(1,'brad', 38, 'M');
--insert into Employee2(Id, name, age, sex) values(1,'brad', 38, 'M');
--insert into Employee2(Id, name, age, sex) values(2,'Tom', 28, 'M');
--insert into Employee2(Id, name, age, sex) values(3,'Jack', 22, 'M');
--insert into Employee2(Id, name, age, sex) values(4,'Jerry', 26, 'M');
--insert into Employee2(Id, name, age, sex) values(4,'Jerry', 26, 'M');
--insert into Employee2(Id, name, age, sex) values(5,'Mary', 18, 'F');

SELECT Id, name, age, sex, count(*)
FROM Employee2
GROUP BY Id, name, age, sex
HAVING count(*) > 1


WITH cte
AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY Id, name, age, sex ORDER BY ID DESC) AS RowID,
Id, name, age, sex
 FROM [BRAD].[dbo].[Employee2] 
)
select * from cte WHERE RowID>1
--DELETE FROM cte WHERE RowID>1

SELECT Id, name, age, sex, count(*)
FROM Employee2
GROUP BY Id, name, age, sex
HAVING count(*) > 1


-- sample 2
--insert into Employee(Id, name) values(1,'brad');
--insert into Employee(Id, name) values(1,'brad');
--insert into Employee(Id, name) values(1,'brad');
--insert into Employee(Id, name) values(2,'Tom');
--insert into Employee(Id, name) values(3,'Jack');
--insert into Employee(Id, name) values(4,'Jerry');
--insert into Employee(Id, name) values(4,'Jerry');
--insert into Employee(Id, name) values(5,'Mary');

SELECT Id, name, count(*)
FROM Employee
GROUP BY Id, name
HAVING count(*) > 1

SELECT col1, col2, count(*)
FROM t1
GROUP BY col1, col2
HAVING count(*) > 1


-- 查詢隱藏欄位%%physloc%%
select %%physloc%% as rowid, * from Employee;

-- 利用隱藏欄位刪除重複資料
delete from Employee where %%physloc%% = 0x2004000001000100



-- Method 2
--How to remove duplicate rows from a table in SQL Server
--https://support.microsoft.com/en-us/help/139444/how-to-remove-duplicate-rows-from-a-table-in-sql-server


--1.	First, run the above GROUP BY query to determine how many sets of duplicate PK values exist, and the count of duplicates for each set.
--2.	Select the duplicate key values into a holding table. For example:
--SELECT col1, col2, col3=count(*)
--INTO holdkey
--FROM t1
--GROUP BY col1, col2
--HAVING count(*) > 1
--3.	Select the duplicate rows into a holding table, eliminating duplicates in the process. For example:
--SELECT DISTINCT t1.*
--INTO holddups
--FROM t1, holdkey
--WHERE t1.col1 = holdkey.col1
--AND t1.col2 = holdkey.col2
--4.	At this point, the holddups table should have unique PKs, however, this will not be the case if t1 had duplicate PKs, yet unique rows (as in the SSN example above). Verify that each key in holddups is unique, and that you do not have duplicate keys, yet unique rows. If so, you must stop here and reconcile which of the rows you wish to keep for a given duplicate key value. For example, the query:
--SELECT col1, col2, count(*)
--FROM holddups
--GROUP BY col1, col2
--should return a count of 1 for each row. If yes, proceed to step 5 below. If no, you have duplicate keys, yet unique rows, and need to decide which rows to save. This will usually entail either discarding a row, or creating a new unique key value for this row. Take one of these two steps for each such duplicate PK in the holddups table.
--5.	Delete the duplicate rows from the original table. For example:
--DELETE t1
--FROM t1, holdkey
--WHERE t1.col1 = holdkey.col1
--AND t1.col2 = holdkey.col2
--6.	Put the unique rows back in the original table. For example:
--INSERT t1 SELECT * FROM holddups



--Find and Remove Duplicate Rows from a SQL Server Table
--https://www.mssqltips.com/sqlservertip/4486/find-and-remove-duplicate-rows-from-a-sql-server-table/
