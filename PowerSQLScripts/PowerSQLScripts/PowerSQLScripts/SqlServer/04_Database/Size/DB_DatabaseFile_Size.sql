-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Database file size 資料庫檔案大小
-- sys.database_files (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-files-transact-sql
-- TSQL for database size, data and log available size
-- https://blogs.msdn.microsoft.com/batuhanyildiz/2013/01/07/tsql-for-database-size-data-and-log-available-size/
-- sp_spaceused (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-spaceused-transact-sql
-- =============================================


USE [tempdb];
SELECT
s.name AS [Name],
s.physical_name AS [FileName],
s.size * CONVERT(float,8) AS [Size_KB],
CAST(CASE s.type WHEN 2 THEN 0 ELSE CAST(FILEPROPERTY(s.name, 'SpaceUsed') AS float)* CONVERT(float,8) END AS float) AS [UsedSpace_KB],
s.file_id AS [ID], g.name
FROM
sys.filegroups AS g
INNER JOIN sys.master_files AS s ON ((s.type = 2 or s.type = 0) and s.database_id = db_id() and (s.drop_lsn IS NULL)) AND (s.data_space_id=g.data_space_id)
--WHERE 
--CAST(cast(g.name as varbinary(256)) AS sysname)='PRIMARY'
ORDER BY [ID] ASC


--Name	FileName	Size_KB	UsedSpace_KB	ID	name
--tempdev	T:\MSSQL10_50.MSSQLSERVER\MSSQL\Data\tempdb.mdf	8388608	37824	1	PRIMARY
--tempdev2	T:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdev2.ndf	8388608	36160	3	PRIMARY
--tempdev3	T:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdev3.ndf	8388608	37888	4	PRIMARY
--tempdev4	T:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\tempdev4.ndf	8388608	37376	5	PRIMARY



-- file size and file group
SELECT DB_NAME() AS DbName,
name AS FileName,
FILEGROUP_NAME(data_space_id) as FileGroup,
size/128.0 AS CurrentSizeMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files;