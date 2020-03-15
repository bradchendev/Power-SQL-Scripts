-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2020/3/15
-- Description:	以AdventureWorks資料庫的SalesOrderDetail資料表啟用Partition Table範例

-- =============================================
USE [master]
GO
ALTER DATABASE [AdventureWorks2] ADD FILEGROUP [FG1]
GO
ALTER DATABASE [AdventureWorks2] ADD FILE ( NAME = N'AdventureWorks_Data1', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\AdventureWorks_Data1.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [FG1]
GO
ALTER DATABASE [AdventureWorks2] ADD FILEGROUP [FG2]
GO
ALTER DATABASE [AdventureWorks2] ADD FILE ( NAME = N'AdventureWorks_Data2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\AdventureWorks_Data2.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [FG2]
GO

BEGIN TRANSACTION
CREATE PARTITION FUNCTION [demoPF](datetime) AS RANGE RIGHT FOR VALUES (N'2001-01-01T00:00:00', N'2002-01-01T00:00:00', N'2003-01-01T00:00:00', N'2004-01-01T00:00:00', N'2005-01-01T00:00:00')
 
CREATE PARTITION SCHEME [demoPS] AS PARTITION [demoPF] TO ([FG2], [FG2], [FG1], [FG1], [PRIMARY], [PRIMARY])
 
ALTER TABLE [Sales].[SalesOrderDetail] DROP CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID]
 
ALTER TABLE [Sales].[SalesOrderHeaderSalesReason] DROP CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID]
 
ALTER TABLE [Sales].[SalesOrderHeader] DROP CONSTRAINT [PK_SalesOrderHeader_SalesOrderID]
 
ALTER TABLE [Sales].[SalesOrderHeader] ADD  CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY NONCLUSTERED 
(
 [SalesOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
 
CREATE CLUSTERED INDEX [ClusteredIndex_on_demoPS_635068046487017900] ON [Sales].[SalesOrderHeader]
(
 [OrderDate]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [demoPS]([OrderDate])
 
DROP INDEX [ClusteredIndex_on_demoPS_635068046487017900] ON [Sales].[SalesOrderHeader]
 
ALTER TABLE [Sales].[SalesOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID] FOREIGN KEY([SalesOrderID])
REFERENCES [Sales].[SalesOrderHeader] ([SalesOrderID])
ON DELETE CASCADE
ALTER TABLE [Sales].[SalesOrderDetail] CHECK CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID]
 
ALTER TABLE [Sales].[SalesOrderHeaderSalesReason]  WITH CHECK ADD  CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID] FOREIGN KEY([SalesOrderID])
REFERENCES [Sales].[SalesOrderHeader] ([SalesOrderID])
ON DELETE CASCADE
ALTER TABLE [Sales].[SalesOrderHeaderSalesReason] CHECK CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID]
 
COMMIT TRANSACTION



SELECT
  p.partition_number ,
  p.rows ,
  p.index_id
FROM sys.partitions AS p
  JOIN sys.tables AS t ON  p.object_id = t.object_id
WHERE p.partition_id IS NOT NULL
    AND t.name = 'SalesOrderHeader'