-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://bradctchen.blogspot.com/
-- Create date: 2017/7/8
-- Description:	Server Configuration 

-- =============================================


--sp_configure (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188787.aspx

USE master;  
GO  
EXEC sp_configure 'show advanced option', '1';  
GO

--USE master;  
--GO  
--EXEC sp_configure 'recovery interval', '3';  
--RECONFIGURE WITH OVERRIDE;


--Server Configuration Options (SQL Server)
--https://msdn.microsoft.com/en-us/library/ms189631.aspx

--Configure the max degree of parallelism Server Configuration Option
--https://msdn.microsoft.com/en-us/library/ms189094.aspx

--Server Memory Server Configuration Options
--https://msdn.microsoft.com/en-us/library/ms178067.aspx

