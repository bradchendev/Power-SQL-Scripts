-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	DBCC TRACEON 

-- =============================================



--The following example displays the status of all trace flags that are currently enabled globally.
DBCC TRACESTATUS(-1);  
GO 

-- [globally]
--The following example displays whether trace flag 3205 is enabled globally.
DBCC TRACESTATUS (3205, -1);  
GO  
--The following example lists all the trace flags that are enabled for the current session.
DBCC TRACESTATUS();  
GO


-- [current connection]
--The following example disables hardware compression for tape drivers, by switching on trace flag 3205. This flag is switched on only for the current connection.
DBCC TRACEON (3205);  
GO 

--The following example switches on trace flag 3205 globally.
DBCC TRACEON (3205, -1);  
GO
-- The following example switches on trace flags 3205, and 260 globally.
DBCC TRACEON (3205, 260, -1);  
GO 


--disables trace flag
--DBCC TRACEOFF (3205);   
--GO
--DBCC TRACEOFF (3205, -1);   
--GO 
--DBCC TRACEOFF (3205, 260, -1);  
--GO  

--DBCC TRACESTATUS (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187809.aspx
--DBCC TRACEON (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187329.aspx
--DBCC TRACEOFF (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms174401.aspx


