-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	Openquery

-- =============================================


--OPENQUERY (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188427.aspx


SELECT * FROM OPENQUERY(LinkedServer1,'SELECT au_lname, au_id FROM pubs..authors')



--Examples
--A. Executing an UPDATE pass-through query
--The following example uses a pass-through UPDATE query against the linked server created in example A.
UPDATE OPENQUERY (OracleSvr, 'SELECT name FROM joe.titles WHERE id = 101')   
SET name = 'ADifferentName';  

--B. Executing an INSERT pass-through query
--The following example uses a pass-through INSERT query against the linked server created in example A.
INSERT OPENQUERY (OracleSvr, 'SELECT name FROM joe.titles')  
VALUES ('NewTitle');  

--C. Executing a DELETE pass-through query
--The following example uses a pass-through DELETE query to delete the row inserted in example C.
DELETE OPENQUERY (OracleSvr, 'SELECT name FROM joe.titles WHERE name = ''NewTitle''');  


--How to pass a variable to a linked server query
--https://support.microsoft.com/en-us/kb/314520

--Pass Basic Values
--When the basic Transact-SQL statement is known, but you have to pass in one or more specific values, use code that is similar to the following sample: 
      DECLARE @TSQL varchar(8000), @VAR char(2)
      SELECT  @VAR = 'CA'
      SELECT  @TSQL = 'SELECT * FROM OPENQUERY(MyLinkedServer,''SELECT * FROM pubs.dbo.authors WHERE state = ''''' + @VAR + ''''''')'
      EXEC (@TSQL)
				

--Pass the Whole Query
--When you have to pass in the whole Transact-SQL query or the name of the linked server (or both), use code that is similar to the following sample:
DECLARE @OPENQUERY nvarchar(4000), @TSQL nvarchar(4000), @LinkedServer nvarchar(4000)
SET @LinkedServer = 'MyLinkedServer'
SET @OPENQUERY = 'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''
SET @TSQL = 'SELECT au_lname, au_id FROM pubs..authors'')' 
EXEC (@OPENQUERY+@TSQL) 
				


--Use the Sp_executesql Stored Procedure
--To avoid the multi-layered quotes, use code that is similar to the following sample:
DECLARE @VAR char(2)
SELECT  @VAR = 'CA'
EXEC MyLinkedServer.master.dbo.sp_executesql
     N'SELECT * FROM pubs.dbo.authors WHERE state = @state',
     N'@state char(2)',
     @VAR
			
