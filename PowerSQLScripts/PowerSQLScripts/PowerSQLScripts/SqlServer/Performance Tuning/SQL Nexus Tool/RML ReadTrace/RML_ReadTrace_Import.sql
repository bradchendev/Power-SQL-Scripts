-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/8/3
-- Description:	  RML Utilities 

-- =============================================

--1.Create database for import trc file
CREATE DATABASE [ReadTraceDB20161020213501] ON  PRIMARY 
( NAME = N'ReadTraceDB20161020213501', 
FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\ReadTraceDB20161020213501.mdf' , 
SIZE = 5120000KB , MAXSIZE = UNLIMITED, FILEGROWTH = 204800KB )
 LOG ON 
( NAME = N'ReadTraceDB20161020213501_log', 
FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\ReadTraceDB20161020213501_log.ldf' , 
SIZE = 512000KB , MAXSIZE = 2048GB , FILEGROWTH = 204800KB )
GO
	ALTER DATABASE [ReadTraceDB20161020213501] SET RECOVERY SIMPLE 
GO

--2.import
--Cd C:\Program Files\Microsoft Corporation\RMLUtils
--ReadTrace.exe -S"(local)" -E -d"ReadTraceDB20161020213501" -I"D:\TEMP\SQLTraceFiles\2016-10-20_21-35-01\TPECDB08_20161020212501.trc" -o"D:\TEMP\SQLTraceFiles\2016-10-20_21-35-01\output"

--修改參數
---d後面的資料庫名稱
---l要匯入第一個trc檔
---o指定一個執行匯入過程的紀錄檔目錄


--3.Import完成後自動啟動Reporter