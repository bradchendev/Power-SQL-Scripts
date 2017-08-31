-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Table Create and Alter 資料表_建立與修改
-- CREATE TABLE (Transact-SQL) 
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql
-- =============================================



--To create a primary key in a new table
USE AdventureWorks2012;  
GO  
CREATE TABLE Production.TransactionHistoryArchive1  
(  
   TransactionID int NOT NULL,  
   CONSTRAINT PK_TransactionHistoryArchive_TransactionID PRIMARY KEY CLUSTERED (TransactionID)  
);  
GO

--To create a primary key in an existing table
USE AdventureWorks2012;  
GO  
ALTER TABLE Production.TransactionHistoryArchive   
ADD CONSTRAINT PK_TransactionHistoryArchive_TransactionID PRIMARY KEY CLUSTERED (TransactionID);  
GO  



-- 資料表_建立相同schema資料表
CREATE TABLE [dbo].[Table_4]
(
	[c1] [int] IDENTITY(1,1) PRIMARY KEY,
	[c2] [nchar](10) NULL
	)

-- 會保留Identity設定
select * into dbo.Table_4_1
from dbo.Table_4 where 1=0 


-- 不會保留Identity設定
select * into dbo.Table_4_2 
from dbo.Table_4 where 1=0
union all
select * 
from dbo.Table_4 where 1=0


-- 不會保留Identity也不會保留not allow null
select top 0
	B.*
into
	dbo.TargetTable
from
	dbo.Table_6 as A
	left join dbo.Table_6 as B on 1 = 0
				


-- create table with primary key (clustered index)
create table Orders
(
ordid varchar(250) primary key
,prodname nvarchar(200)
)
--or
-- create table with primary key (clustered index)
create table Orders
(
ordid varchar(250) not null
CONSTRAINT PK_Orders  
               PRIMARY KEY CLUSTERED (ordid)  
               WITH (IGNORE_DUP_KEY = OFF)  
,prodname nvarchar(200)
)




-- create table with FOREIGN KEY 
create table OrdersDetail
(
ordetailid varchar(250) primary key
,ordid varchar(250) REFERENCES Orders(ordid)  
);

-- or
-- create table with FOREIGN KEY 
create table OrdersDetail
(
ordetailid varchar(250) primary key
,ordid varchar(250) 
	CONSTRAINT FK_Orders_OrdersDetail FOREIGN KEY  
	 (ordid)  
	REFERENCES Orders (ordid)  
);


-- or
-- create table with FOREIGN KEY 
create table OrdersDetail
(
ordetailid varchar(250) 
CONSTRAINT PK_OrdersDetail 
               PRIMARY KEY CLUSTERED (ordetailid)  
               WITH (IGNORE_DUP_KEY = OFF)  
               
,ordid varchar(250) 
	CONSTRAINT FK_Orders_OrdersDetail FOREIGN KEY  
	 (ordid)  
	REFERENCES Orders (ordid)  
);


-- 移除OrdersDetail表的FOREIGN KEY 並修改欄位資料型別
ALTER TABLE [dbo].[OrdersDetail] DROP CONSTRAINT [FK_Orders_OrdersDetail]
GO
ALTER TABLE [dbo].[OrdersDetail] ALTER COLUMN ordid int;  
GO

-- 移除Orders表的PRIMARY KEY 並修改欄位資料型別
ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [PK_Orders]
GO
ALTER TABLE [dbo].[Orders] ALTER COLUMN ordid int;  
GO

-- 加回OrdersDetail表的FOREIGN KEY 
ALTER TABLE [dbo].[OrdersDetail] 
ADD CONSTRAINT [FK_Orders_OrdersDetail] FOREIGN KEY (ordid)     
    REFERENCES dbo.[Orders] (ordid);    











-- ALTER TABLE (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms190273.aspx#alter_column
-- Add column
ALTER TABLE [Tablename]
ADD [Rowversion] Rowversion NOT NULL

ALTER TABLE dbo.doc_exa 
ADD column_b VARCHAR(20) NULL ;  

ALTER TABLE dbo.doc_exc 
ADD column_b VARCHAR(20) NULL   
    CONSTRAINT exb_unique UNIQUE ; 
    
ALTER TABLE dbo.doc_exz  
ADD CONSTRAINT col_b_def  
DEFAULT 50 FOR column_b ; 

--Creating a PRIMARY KEY constraint with index options
ALTER TABLE Production.TransactionHistoryArchive WITH NOCHECK   
ADD CONSTRAINT PK_TransactionHistoryArchive_TransactionID PRIMARY KEY CLUSTERED (TransactionID)  
WITH (FILLFACTOR = 75, ONLINE = ON, PAD_INDEX = ON);  



-- Remove a single column.  
ALTER TABLE dbo.doc_exb DROP COLUMN column_b ;  
GO  
-- Remove multiple columns.  
ALTER TABLE dbo.doc_exb DROP COLUMN column_c, column_d;  


-- Changing the data type of a column
ALTER TABLE dbo.doc_exy ALTER COLUMN column_a DECIMAL (5, 2) ;  

-- Increase the size of the varchar column.  
ALTER TABLE dbo.doc_exy ALTER COLUMN col_a varchar(25);  
GO  
-- Increase the scale and precision of the decimal column.  
ALTER TABLE dbo.doc_exy ALTER COLUMN col_b decimal (10,4);  
GO 

-- change Allow NULL
ALTER TABLE your_table
ALTER COLUMN your_column NVARCHAR(42) NULL




-- 把資料表Table_1所有欄位修改為允許null (allow null)

--	DECLARE @DB_ NVARCHAR(100) = 'AdventureWorks2008R2' 
--	DECLARE @SCHEMA_ NVARCHAR(100) = 'dbo' 
--	DECLARE @TABLE_ NVARCHAR(100) = 'Table_1' 

--	DECLARE @sql nvarchar(1000)

--SET @sql = '
--select 
--''ALTER TABLE ['' + sch.name +''].['' + tbl.name + ''] ALTER COLUMN ['' + col.name + ''] '' + typ.name  +
--CASE when typ.name in (''datetime'',''int'',''bigint'') then '' null'' else ''('' +CAST(col.max_length AS varchar)+'') null'' end 
-- from sys.columns col 
--inner join sys.tables tbl 
--on col.[object_id] = tbl.[object_id] and tbl.is_ms_shipped = 0 
--inner join sys.schemas sch 
--on tbl.[schema_id] = sch.[schema_id] 
--inner join muchnewdb.sys.types typ 
--on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id 
--where col.is_nullable = 0 
--and sch.name=''' + @SCHEMA_ + ''' and tbl.name=''' + @DB_  + '_' + @TABLE_; 
--'

--select @sql
