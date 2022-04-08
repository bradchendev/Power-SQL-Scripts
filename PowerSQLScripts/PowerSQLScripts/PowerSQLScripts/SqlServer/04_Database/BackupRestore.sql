-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Backup and Restore Database 備份與還原資料庫
 -- Back Up and Restore of SQL Server Databases
 -- https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases
-- =============================================

-- 查詢備份檔紀錄
SELECT 
 bs.backup_set_id,
 bs.database_name,
 bs.backup_start_date,
 bs.backup_finish_date,
 CAST(CAST(bs.backup_size/1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS [Size],
 CAST(DATEDIFF(second, bs.backup_start_date,
 bs.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' [TimeTaken],
 CASE bs.[type]
 WHEN 'D' THEN 'Full Backup'
 WHEN 'I' THEN 'Differential Backup'
 WHEN 'L' THEN 'TLog Backup'
 WHEN 'F' THEN 'File or filegroup'
 WHEN 'G' THEN 'Differential file'
 WHEN 'P' THEN 'Partial'
 WHEN 'Q' THEN 'Differential Partial'
 END AS BackupType,
 bs.is_copy_only,
 bmf.physical_device_name,
 CAST(bs.first_lsn AS VARCHAR(50)) AS first_lsn,
 CAST(bs.last_lsn AS VARCHAR(50)) AS last_lsn,
 bs.server_name,
 bs.recovery_model
 From msdb.dbo.backupset bs
 INNER JOIN msdb.dbo.backupmediafamily bmf 
 ON bs.media_set_id = bmf.media_set_id
 ORDER BY bs.server_name,bs.database_name,bs.backup_start_date;
 GO
--透過SERVER_NAME欄位，可以判斷該備份檔是否是在這台SQL Server上執行的備份
--如果SERVER_NAME欄位顯示別台SQL Server主機名稱，表示這個備份檔是從別台SQL Server複製過來並且在這台執行過RESTORE


--查詢還原紀錄
SELECT rs.[restore_history_id]
 ,rs.[restore_date]
 ,rs.[destination_database_name]
 ,bmf.physical_device_name
 ,rs.[user_name]
 ,rs.[backup_set_id]
 ,CASE rs.[restore_type]
 WHEN 'D' THEN 'Database'
 WHEN 'I' THEN 'Differential'
 WHEN 'L' THEN 'Log'
 WHEN 'F' THEN 'File'
 WHEN 'G' THEN 'Filegroup'
 WHEN 'V' THEN 'Verifyonlyl'
 END AS RestoreType
 ,rs.[replace]
 ,rs.[recovery]
 ,rs.[restart]
 ,rs.[stop_at]
 ,rs.[device_count]
 ,rs.[stop_at_mark_name]
 ,rs.[stop_before]
 FROM [msdb].[dbo].[restorehistory] rs
 inner join [msdb].[dbo].[backupset] bs
 on rs.backup_set_id = bs.backup_set_id
 INNER JOIN msdb.dbo.backupmediafamily bmf 
 ON bs.media_set_id = bmf.media_set_id
 GO
 --PS.RESTORE操作會寫入backupset與backupmediafamily資料表，紀錄還原所使用的備份檔資訊



 

-- resotre 所有檔案都需要指定位置，不可減少，但可以指定到新位置
RESTORE DATABASE [MyDB2B] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\MyDB2.bak' WITH  FILE = 1,  
MOVE N'MyDB2' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B.mdf',  
MOVE N'MyDB2_D1' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B_1.ndf',  
MOVE N'MyDB2_D2' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B_2.ndf',  
MOVE N'MyDB2_D7' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B_3.ndf',  
MOVE N'MyDB2_D8' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B_4.ndf',  
MOVE N'MyDB2_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2B_5.ldf',  
NOUNLOAD,  REPLACE,  STATS = 10
GO

-- restore之後才能刪減資料檔



-- 從備份檔查詢實體檔案路徑
restore FILELISTONLY FROM DISK = N'\\DBFS1\DB_Backup\MyDB2\full\MyDB2\MyDB2_backup_2016_10_23_000101_3046971.bak'

-- 還原時指定實體檔案到新的位置
restore database [MyDB2]
FROM DISK = N'\\DBFS1\DB_Backup\MyDB2\full\MyDB2\MyDB2_backup_2016_10_23_000101_3046971.bak'
WITH RECOVERY,
   MOVE 'MyDB2' TO 'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2.mdf', 
   MOVE 'MyDB2_log' TO 'D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\MyDB2.ldf'