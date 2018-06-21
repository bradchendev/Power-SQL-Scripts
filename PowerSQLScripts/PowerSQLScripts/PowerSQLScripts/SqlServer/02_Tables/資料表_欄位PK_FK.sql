-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	資料表_欄位PK_FK.sql

-- =============================================

-- foreign_keys
select 
object_name(parent_object_id) as [TableName],
name as [foreign_key],
object_name(referenced_object_id) as [referenced_Table]
 from sys.foreign_keys
 order by [TableName]


 -- PK
 CREATE VIEW dbo.AllPrimaryKeyColumns 
 AS
 SELECT 
 s.name as schemaname, 
 t.name as tablename, 
 c.name as columnname, 
 ic.index_column_id as keycolumnnumber
 FROM sys.index_columns ic
 inner join sys.columns c on ic.object_id = c.object_id and ic.column_id = c.column_id
 inner join sys.indexes i on ic.object_id = i.object_id and ic.index_id = i.index_id
 inner join sys.tables t on i.object_id = t.object_id
 inner join sys.schemas s on t.schema_id = s.schema_id
 WHERE i.is_primary_key= 1;

 -- All Table, if no PK then pk.[columnname] = null
SELECT 
schema_name(tb.schema_id) as [schema],
tb.name, 
pk.[columnname] as [PK_col] 
FROM sys.tables as tb
left join AllPrimaryKeyColumns as pk
on tb.name = pk.tablename and schema_name(tb.schema_id) = pk.schemaname
-- WHERE tb.name  in ('table1','table2')
-- and  pk.[columnname] is null
ORDER BY 
	schema_name(tb.schema_id),
	tb.name,
	pk.keycolumnnumber



 -- PK
  ;WITH tables_with_pk AS (
  SELECT t.table_schema, t.table_name  
  FROM INFORMATION_SCHEMA.TABLES t 
    INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
      ON t.TABLE_NAME = tc.TABLE_NAME AND t.table_schema = tc.table_schema
  WHERE tc.constraint_type = 'PRIMARY KEY'
)
SELECT t.table_schema, t.table_name 
FROM INFORMATION_SCHEMA.TABLES t 
EXCEPT
SELECT table_schema, table_name
FROM tables_with_pk