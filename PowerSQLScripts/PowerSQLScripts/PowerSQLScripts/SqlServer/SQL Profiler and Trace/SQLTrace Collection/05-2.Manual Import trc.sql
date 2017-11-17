
--1.在 ReadTrace用的SQL Server建立一個ReadTrace匯入DB 
--若使用下方範例，請將下方的20161020213501都改為這次的日期時間(你可以這次的trace目錄的名稱去除”-“符號當作資料庫名稱) 
  
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
  

--2.匯入trc檔到RML ReadTrace分析工具 
  
--管理員身分啟動一個命令提示字元 
 
  
--執行以下命令 
--1.先切換到以下目錄 
--Cd C:\Program Files\Microsoft Corporation\RMLUtils 
  
--2.再執行ReadTrace.exe來匯入 
--請先修改以下的參數 
---d後面的資料庫名稱 
---l要匯入第一個trc檔 
---o指定一個執行匯入過程的紀錄檔目錄 
  
--ReadTrace.exe -S"(local)" -E -d"ReadTraceDB20161020213501" -I"D:\TEMP\SQLTraceFiles\2016-10-20_21-35-01\TPECDB08_20161020212501.trc" -o"D:\TEMP\SQLTraceFiles\2016-10-20_21-35-01\output" 
  

