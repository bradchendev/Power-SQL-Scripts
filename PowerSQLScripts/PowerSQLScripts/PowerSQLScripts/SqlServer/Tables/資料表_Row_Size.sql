-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	資料表筆數與大小_Row_Size

-- =============================================




-- 目前column設計的max size

--Maximum Size of Index Keys
--https://technet.microsoft.com/en-us/library/ms191241(v=sql.105).aspx
--SELECT SUM(max_length)AS TotalIndexKeySize
--FROM sys.columns
--WHERE name IN (N'AddressLine1', N'AddressLine2', N'City', N'StateProvinceID', N'PostalCode')
--AND object_id = OBJECT_ID(N'Person.Address');

SELECT SUM(max_length) AS RowMaxSize_bytes
FROM sys.columns
WHERE [object_id] = OBJECT_ID(N'Sales.SalesOrderHeader');


SELECT col.name, typ.name as [DataType], col.max_length
FROM sys.columns	col 
inner join sys.types typ
	on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id
WHERE [object_id] = OBJECT_ID(N'Sales.SalesOrderHeader');

-- sys.columns.max_length = -1  ->  (max)
-- max indicates that the maximum storage size is 2^31-1 bytes (2 GB)

-- nchar(50) = 50 bytes = unicode所以儲存佔用空間為50 bytes x2 = 100 Bytes

--nchar and nvarchar (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms186939.aspx
--nchar [ ( n ) ]
--Fixed-length Unicode string data. n defines the string length and must be a value from 1 through 4,000. The storage size is two times n bytes. When the collation code page uses double-byte characters, the storage size is still n bytes. Depending on the string, the storage size of n bytes can be less than the value specified for n. The ISO synonyms for nchar are national char and national character..
--nvarchar [ ( n | max ) ]
--Variable-length Unicode string data. n defines the string length and can be a value from 1 through 4,000. max indicates that the maximum storage size is 2^31-1 bytes (2 GB). The storage size, in bytes, is two times the actual length of data entered + 2 bytes. The ISO synonyms for nvarchar are national char varying and national character varying.






-- 目前的資料裡面max row size
-- 新版
SELECT min_record_size_in_bytes,
max_record_size_in_bytes,
avg_record_size_in_bytes
 FROM sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2008R2'), OBJECT_ID(N'[Sales].[SalesOrderHeader]'), NULL, NULL , 'DETAILED')

SELECT min_record_size_in_bytes,
max_record_size_in_bytes,
avg_record_size_in_bytes
 FROM sys.dm_db_index_physical_stats (DB_ID(N'AdventureWorks2008R2'), OBJECT_ID(N'[Sales].[SalesOrderHeader]'), NULL, NULL , 'DETAILED')
--PS.在DEV3測試查詢耗時



-- 舊版
dbcc showcontig ('SalesOrderHeader') with tableresults
--MinimumRecordSize	Minimum record size in that level of the index or whole heap.
--MaximumRecordSize Maximum record size in that level of the index or whole heap.