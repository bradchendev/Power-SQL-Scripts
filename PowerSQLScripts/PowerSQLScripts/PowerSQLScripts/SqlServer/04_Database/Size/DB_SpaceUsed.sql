

USE AdventureWorks2017;  
GO  
EXEC sp_spaceused;  
GO

--database_name	database_size	unallocated space
--AdventureWorks2017	336.00 MB	57.19 MB

--reserved	data	index_size	unused
--211776 KB	97384 KB	87264 KB	27128 KB



USE AdventureWorks2017;  
GO  
EXEC sp_spaceused N'Purchasing.Vendor';  
GO
--name	rows	reserved	data	index_size	unused
--Vendor	104                 	272 KB	16 KB	32 KB	224 KB
