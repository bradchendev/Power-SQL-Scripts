-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Index 建立與變更
-- CREATE INDEX (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-index-transact-sql

-- =============================================

/*
USE [AdventureWorks2008R2]
GO
CREATE NONCLUSTERED INDEX [IX_Orders_valid] 
ON [dbo].[Orders] ([valid])
    WITH (FILLFACTOR = 80,  
        PAD_INDEX = ON,  
        DROP_EXISTING = ON,
        ONLINE = ON);  
        
GO
*/


-- Create a Primary key clustered index in exist table
ALTER TABLE [dbo].[t1] ALTER COLUMN col1 int NOT NULL;
ALTER TABLE [dbo].[t1]
   ADD CONSTRAINT PK_t1_col1 PRIMARY KEY CLUSTERED (col1);




-- Create a nonclustered index on a table or view  
CREATE INDEX i1 ON t1 (col1);  

--Create a clustered index on a table and use a 3-part name for the table  
CREATE CLUSTERED INDEX i1 ON d1.s1.t1 (col1);  

-- Create a nonclustered index with a unique constraint on 3 columns and specify the sort order for each column  
CREATE UNIQUE INDEX i1 ON t1 (col1 DESC, col2 ASC, col3 DESC);  



-- 加總欄位的最大值，確保沒有超過最大值900-Bytes
-- Maximum Size of Index Keys
-- https://technet.microsoft.com/en-us/library/ms191241(v=sql.105).aspx

-- nvarchar(200) => max_length =  400

USE AdventureWorks2008R2;
GO
SELECT SUM(max_length)AS TotalIndexKeySize
FROM sys.columns
WHERE name IN (N'AddressLine1', N'AddressLine2', N'City', N'StateProvinceID', N'PostalCode')
AND object_id = OBJECT_ID(N'Person.Address');



