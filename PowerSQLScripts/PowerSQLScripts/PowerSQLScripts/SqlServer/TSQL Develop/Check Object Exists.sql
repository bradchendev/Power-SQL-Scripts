-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	Check Object Exists

-- =============================================

IF EXISTS (select 1 from sys.objects where name like '%AddressType%')
	PRINT 'Object Exists'
ELSE
	PRINT 'Object not exists'


select 
[name],
SCHEMA_NAME(schema_id) AS [SCHEMA],
[type_desc],
[create_date],
[modify_date],
[is_ms_shipped],
[parent_object_id]
from sys.objects
where [name] like '%AddressType%'
--where [name] like '%uspGetBillOfMaterials%'
--where [name] like '%vEmployee%'
--where [name] like '%ufnGetAccountingEndDate%'


