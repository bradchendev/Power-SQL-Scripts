-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Recover_missing_sa_password

-- =============================================

--Troubleshooting: Connecting to SQL Server When System Administrators Are Locked Out
--https://msdn.microsoft.com/en-us/library/dd207004(v=sql.105).aspx

--Start the instance of SQL Server in single-user mode by using either the -m or -f options. 
--Any member of the computer's local Administrators group can then connect to the instance of SQL Server as a member of the sysadmin fixed server role.

--1.Start the instance of SQL Server in single-user mode by using either the -m or -f options

-- sqlservr.exe -m"sqlcmd"
-- Single-User Mode
-- limits connections to a single connection and that connection must identify itself as the sqlcmd client program.
--or 
-- sqlservr.exe -m"Microsoft SQL Server Management Studio - Query". 


-- 2.
-- C:\> sqlcmd -S "(local)"
--
--CREATE LOGIN newSa WITH PASSWORD = 'xxxxxx'
--Go
--sp_addsrvrolemember 'newSa', 'sysadmin'
--go