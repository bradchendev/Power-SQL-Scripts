-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Linked Server Dependencies 

-- =============================================



-- Only for four-part name
-- cannot get Openquery
--
-- sys.sql_expression_dependencies (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/bb677315.aspx

--referenced_server_name	sysname	Name of the server of the referenced entity.

--This column is populated for cross-server dependencies that are made by specifying a valid four-part name. For information about multipart names, see Transact-SQL Syntax Conventions (Transact-SQL).
--NULL for non-schema-bound entities for which the entity was referenced without specifying a four-part name.
--NULL for schema-bound entities because they must be in the same database and therefore can only be defined using a two-part (schema.object) name.

-- 找出使用Linked server的物件(Stored procedure, view, function...)
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,   
    o.type_desc AS referencing_desciption,  
    referenced_server_name, referenced_database_name, referenced_schema_name,  
    referenced_entity_name   
FROM sys.sql_expression_dependencies AS sed  
INNER JOIN sys.objects AS o 
ON sed.referencing_id = o.object_id
where referenced_server_name is not null
-- and referenced_server_name='xxx'
order by o.type_desc,referencing_entity_name;



-- 
SELECT OBJECT_NAME(referencing_id) AS referencing_entity_name,   
    o.type_desc AS referencing_desciption,  
    referenced_server_name, referenced_database_name, referenced_schema_name,  
    referenced_entity_name   
FROM sys.sql_expression_dependencies AS sed  
INNER JOIN sys.objects AS o 
ON sed.referencing_id = o.object_id
where referenced_server_name is not null
-- and referenced_server_name='xxx'
order by o.type_desc,referencing_entity_name;

