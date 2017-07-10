-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	EXECUTE AS

-- =============================================

--EXECUTE AS (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms181362.aspx

--Display current execution context.  
SELECT SUSER_NAME(), USER_NAME();  
-- Set the execution context to login1.   
EXECUTE AS LOGIN = 'login1';  
--Verify the execution context is now login1.  
SELECT SUSER_NAME(), USER_NAME();  


EXECUTE AS LOGIN = 'login1';  

