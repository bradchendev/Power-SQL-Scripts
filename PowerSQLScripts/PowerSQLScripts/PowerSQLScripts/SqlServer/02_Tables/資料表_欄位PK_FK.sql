-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	資料表_欄位PK_FK.sql

-- =============================================

select 
object_name(parent_object_id) as [TableName],
name as [foreign_key],
object_name(referenced_object_id) as [referenced_Table]
 from sys.foreign_keys
 order by [TableName]
