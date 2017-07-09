-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	資料表_欄位與描述.sql

-- =============================================



--  計算欄位
select name, definition 
from sys.computed_columns 
where object_id=object_id('Sales.SalesOrderHeader')

-- 基本版
select 
sch.name as [schema],
tbl.name as [Table], 
col.name as [Column],
col.collation_name
 from sys.columns col
inner join sys.tables tbl
on col.[object_id] = tbl.[object_id] and tbl.is_ms_shipped = 0
inner join sys.schemas sch
on tbl.[schema_id] = sch.[schema_id]
where tbl.name = 'SalesOrderHeader'
order by tbl.name, col.column_id





-- v1 這版有問題，欄位會重複，改用v2
--select 
--	sch.name as [schema],
--	tbl.name as [Table], 
--	col.name as [Column],
--	kCst.type as [is_PK],
--	col.is_identity,
--	typ.name as [DataType],
--	col.max_length,
--	col.is_identity,
--	col.is_nullable
--from sys.columns col
--	inner join sys.tables tbl
--	on col.[object_id] = tbl.[object_id] and tbl.is_ms_shipped = 0
--	inner join sys.schemas sch
--	on tbl.[schema_id] = sch.[schema_id]
--	inner join sys.types typ
--	on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id
--	Left join sys.index_columns as ic
--	on ic.[object_id] = tbl.[object_id]
--		and ic.column_id = col.column_id
--	Left join sys.key_constraints kCst
--	on ic.[object_id] = kCst.[parent_object_id] 
--	   and ic.[index_id] = kCst.[unique_index_id]
--order by tbl.name, col.column_id


-- v2
--select 
--	sch.name as [schema],
--	tbl.name as [Table], 
--	col.name as [Column],
--	[PK_Col].[type] as [is_PK],
--	col.is_identity,
--	typ.name as [DataType],
--	col.max_length,
--	col.is_nullable,
--	col.is_computed
--from sys.columns col
--	inner join sys.tables tbl
--	on col.[object_id] = tbl.[object_id] and tbl.is_ms_shipped = 0
--	inner join sys.schemas sch
--	on tbl.[schema_id] = sch.[schema_id]
--	inner join sys.types typ
--	on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id
--	Left join 
--		(select ic.[object_id],ic.[column_id], kCst.[type] from sys.key_constraints as kCst
--		inner join sys.index_columns as ic
--		on kCst.[type] = 'PK' and kCst.[parent_object_id] = ic.[object_id]
--		and kCst.unique_index_id = ic.index_id) as [PK_Col]
--	ON [PK_Col].column_id=col.[column_id] and [PK_Col].[object_id] = tbl.[object_id]
--order by tbl.name, col.column_id


-- v3
-- max_length是儲存空間大小，所以除2才是CREATE TABLE指定的大小
select 
	sch.name as [schema],
	tbl.name as [Table], 
	col.name as [Column],
	[PK_Col].[type] as [is_PK],
	col.is_identity,
	typ.name as [DataType],
	CASE WHEN  typ.name in ('nchar','nvarchar') THEN col.max_length/2
	ELSE col.max_length END as [MaxLength],
	col.is_nullable,
	col.is_computed
from sys.columns col
	inner join sys.tables tbl
	on col.[object_id] = tbl.[object_id] and tbl.is_ms_shipped = 0
	inner join sys.schemas sch
	on tbl.[schema_id] = sch.[schema_id]
	inner join sys.types typ
	on col.system_type_id = typ.system_type_id and col.user_type_id = typ.user_type_id
	Left join 
		(select ic.[object_id],ic.[column_id], kCst.[type] from sys.key_constraints as kCst
		inner join sys.index_columns as ic
		on kCst.[type] = 'PK' and kCst.[parent_object_id] = ic.[object_id]
		and kCst.unique_index_id = ic.index_id) as [PK_Col]
	ON [PK_Col].column_id=col.[column_id] and [PK_Col].[object_id] = tbl.[object_id]
	--where tbl.name = 'SalesOrderHeader'
order by tbl.name, col.column_id


--select * from AdventureWorks2008R2.sys.tables
--select * from AdventureWorks2008R2.sys.columns 
--select * from AdventureWorks2008R2.sys.types
--select * from AdventureWorks2008R2.sys.schemas 



-- computed column definition
--sys.computed_columns (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188744.aspx

select [definition] 
from sys.computed_columns 
where name='SalesOrderNumber'  -- Computed Column Name
and object_id=object_id('Sales.SalesOrderHeader') -- Table






-- 查TABLE描述
SELECT 
	SCHEMA_NAME(tb.[schema_id]) as [Schema],
	tb.name as [Table Name],
	ext_p.name as [Extended Properties Name],
	ext_p.value as [Extended Properties Value]
from 
	sys.tables as tb
	inner join sys.extended_properties as ext_p
	on ext_p.class=1 
	and ext_p.minor_id = 0
	and tb.[object_id]=ext_p.major_id
	--where CAST(ext_p.value as nvarchar(1000)) like '%test%'
ORDER BY [Schema], [Table Name]


-- 查column描述
select 
	SCHEMA_NAME(tb.[schema_id]) as [Schema],
	tb.name as [Table Name],
	col.name as [Column Name],
	--col.column_id,
	ext_p.name as [Extended Properties Name],
	ext_p.value as [Extended Properties Value]
from 
	sys.tables tb
	inner join sys.columns col
	on tb.[object_id] = col.[object_id]
	left join sys.extended_properties ext_p
	on ext_p.class = 1 
		and tb.[object_id]=ext_p.major_id 
		and col.column_id=ext_p.minor_id
ORDER BY [Schema], [Table Name], col.column_id



-- sys.extended_properties (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms177541.aspx
-- class:		1 = Object or column
-- major_id:	If class is 1, 2, or 7 major_id is object_id.
-- minor_id:	If class = 1, minor_id is the column_id if column, else 0 if object.



-- 另一種查欄位描述的方法
-- sys.fn_listextendedproperty (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms179853.aspx
SELECT o.[object_id] AS 'table_id', o.[name] 'table_name',  
0 AS 'column_order', NULL AS 'column_name', NULL AS 'column_datatype',  
NULL AS 'column_length', Cast(e.value AS varchar(500)) AS 'column_description'  
FROM sys.objects AS o  
LEFT JOIN sys.fn_listextendedproperty(N'MS_Description', N'user',N'HumanResources',N'table', N'Employee', null, default) AS e  
    ON o.name = e.objname COLLATE SQL_Latin1_General_CP1_CI_AS  
--WHERE o.name = 'Employee';  
 
 




--資料表
--新增資料表之說明語法：使用sp_addextendedproperty語法，相關參數僅使用到level1的資料表層。
EXEC sys.sp_addextendedproperty @name=N'MS_Description',
                                @value=N'新增加的資料表說明放在這裡',
                                @level0type=N'SCHEMA',
                                @level0name=N'dbo',
                                @level1type=N'TABLE',
                                @level1name=N'table name'

--EXEC sys.sp_dropextendedproperty @name=N'MS_Description',
--                                @level0type=N'SCHEMA',
--                                @level0name=N'dbo',
--                                @level1type=N'TABLE',
--                                @level1name=N'table name'

--欄位
--新增資料表欄位之說明語法：使用sp_addextendedproperty語法，相關參數僅使用到level2的資料表欄位層。
EXEC sys.sp_addextendedproperty @name=N'MS_Description', 
                                @value=N'新增加的欄位說明放在這裡' , 
                                @level0type=N'SCHEMA',
                                @level0name=N'dbo', 
                                @level1type=N'TABLE',
                                @level1name=N'table name', 
                                @level2type=N'COLUMN',
                                @level2name=N'column name'


-- 如果MS_Description已經存在，則用以下方法來修改欄位註解
-- 修改欄位註解
--DECLARE @v sql_variant 
--SET @v = N'備註2'
--EXECUTE sp_updateextendedproperty N'MS_Description', 
--								@v, 
--								N'SCHEMA', 
--								N'dbo', 
--								N'TABLE', 
--								N'ExpressDeliveryFormMaster', 
--								N'COLUMN', 
--								N'Remark'
--GO