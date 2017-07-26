-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/26
-- Description:	Database Role
-- sys.database_principals (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-principals-transact-sql
-- sys.database_role_members (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-role-members-transact-sql
-- sys.database_permissions (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-permissions-transact-sql
-- =============================================




-- list Role
USE AdventrueWorks2008R2;
SELECT * from sys.database_principals
where [type] = 'R';
-- or
SELECT * from AdventrueWorks2008R2.sys.database_principals
where [type] = 'R';


--A: Listing all the permissions of database principals
--The following query lists the permissions explicitly granted or denied to database principals.
--Important
--The permissions of fixed database roles do not appear in sys.database_permissions. Therefore, database principals may have additional permissions not listed here.
SELECT pr.principal_id, pr.name, pr.type_desc,   
    pr.authentication_type_desc, pe.state_desc, pe.permission_name  
FROM sys.database_principals AS pr  
JOIN sys.database_permissions AS pe  
    ON pe.grantee_principal_id = pr.principal_id;



--	B: Listing permissions on schema objects within a database
--The following query joins sys.database_principals and sys.database_permissions to sys.objects and sys.schemas to list permissions granted or denied to specific schema objects.
	SELECT pr.principal_id, pr.name, pr.type_desc,   
    pr.authentication_type_desc, pe.state_desc,   
    pe.permission_name, s.name + '.' + o.name AS ObjectName  
FROM sys.database_principals AS pr  
JOIN sys.database_permissions AS pe  
    ON pe.grantee_principal_id = pr.principal_id  
JOIN sys.objects AS o  
    ON pe.major_id = o.object_id  
JOIN sys.schemas AS s  
    ON o.schema_id = s.schema_id;


	--The following query returns the members of the database roles.
	SELECT DP1.name AS DatabaseRoleName,   
   isnull (DP2.name, 'No members') AS DatabaseUserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
ORDER BY DP1.name;