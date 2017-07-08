-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Database Create and Move 建立資料庫 搬移資料庫
-- Move Database Files
-- https://docs.microsoft.com/en-us/sql/relational-databases/databases/move-database-files
-- Move User Databases
-- https://docs.microsoft.com/en-us/sql/relational-databases/databases/move-user-databases
-- CREATE DATABASE (SQL Server Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-sql-server-transact-sql
-- ALTER DATABASE (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql
-- =============================================

-- Create DB FOR attach_rebuild_log
-- CREATE DATABASE [name] ON (FILENAME = [path to mdf]) FOR ATTACH_REBUILD_LOG 


CREATE DATABASE [MyDb1] ON  PRIMARY 
( NAME = N'MyDb1', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDb1.mdf' , SIZE = 10240000KB , MAXSIZE = UNLIMITED, FILEGROWTH = 204800KB )
 LOG ON 
( NAME = N'MyDb1_log', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDb1_log.ldf' , SIZE = 4096000KB , MAXSIZE = 2048GB , FILEGROWTH = 204800KB )
COLLATE Chinese_Taiwan_Stroke_CI_AS
GO


-- Move
USE master
SELECT name, physical_name FROM sys.master_files 
WHERE database_id = DB_ID('AdventureWorks2008R2');
GO

ALTER DATABASE AdventureWorks2008R2 SET offline
GO


ALTER DATABASE Personnel MODIFY FILE ( NAME =  AdventureWorks2008R2_Data, FILENAME = 'E:\Data\AdventureWorks2008R2_Data.mdf')
GO


ALTER DATABASE AdventureWorks2008R2 SET online
GO


USE master
SELECT name, physical_name FROM sys.master_files 

