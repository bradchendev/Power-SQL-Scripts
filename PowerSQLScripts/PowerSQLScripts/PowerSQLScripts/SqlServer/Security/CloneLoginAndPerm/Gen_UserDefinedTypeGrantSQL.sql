-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/3/29
-- Description: 產生User Defined Type上面的權限 GRANT語法
-- 因為CloneLoginAndPerm.sql不含User Defined Type的權限
-- =============================================


SELECT 
 pe.state_desc COLLATE Latin1_General_CI_AI + N' ' 
 + pe.permission_name COLLATE Latin1_General_CI_AI + N' ON TYPE::[' 
 + sch.name + '].[' 
 + udt.name COLLATE Latin1_General_CI_AI + N'] TO [' 
 + pr.name COLLATE Latin1_General_CI_AI + N']' as [GRANT SQL]
 --select pe.state_desc 
FROM 
	sys.database_permissions AS pe  
	JOIN sys.database_principals AS pr 
    ON pe.grantee_principal_id = pr.principal_id
	LEFT JOIN sys.types AS udt
	ON pe.major_id = udt.[user_type_id] 
	JOIN sys.schemas as sch
	on udt.schema_id = sch.schema_id 
    where pr.name = N'DBUser1'
    and pe.class = 6
