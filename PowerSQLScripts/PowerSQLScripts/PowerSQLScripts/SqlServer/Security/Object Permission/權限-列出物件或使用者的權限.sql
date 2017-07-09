-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	資料表_欄位與描述.sql

-- =============================================


-- 列出資料庫物件上的權限
sp_helprotect uspGetEmployeeManagers


-- 列出使用者權限

--sys.database_permissions (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188367.aspx
-- sys.database_principals (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms187328.aspx
--

SELECT 
	--pr.principal_id, 
	--pe.major_id,
	pr.name as [DB User], 
	pr.type_desc,   
    --pr.authentication_type_desc, --only for sql 2012, 2014, 2016
    pe.state_desc, 
    pe.permission_name,
    --pe.class_desc,
    obj.[type_desc],
    obj.name as [Object Name],
    CASE WHEN minor_id > 0 THEN col.[name] ELSE NULL END as [ifColumn],
    USER_NAME(pe.grantor_principal_id) as [grantor] -- if [grantor] = dbo, db_owner is grantor
FROM 
	sys.database_permissions AS pe  
	JOIN sys.database_principals AS pr 
    ON pe.grantee_principal_id = pr.principal_id
    JOIN sys.objects AS obj
    ON pe.major_id = obj.[object_id]
    LEFT JOIN sys.columns col
    ON pe.major_id = col.[object_id] and pe.minor_id = col.column_id
ORDER BY 
	pr.type_desc, 
	pr.name, 
    obj.name,
	pe.state_desc, 
    pe.permission_name



/*
this code from
http://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database

Security Audit Report
1) List all access provisioned to a sql user or windows user/group directly 
2) List all access provisioned to a sql user or windows user/group through a database or application role
3) List all access provisioned to the public role

Columns Returned:
UserName        : SQL or Windows/Active Directory user cccount.  This could also be an Active Directory group.
UserType        : Value will be either 'SQL User' or 'Windows User'.  This reflects the type of user defined for the 
                  SQL Server user account.
DatabaseUserName: Name of the associated user as defined in the database user account.  The database user may not be the
                  same as the server user.
Role            : The role name.  This will be null if the associated permissions to the object are defined at directly
                  on the user account, otherwise this will be the name of the role that the user is a member of.
PermissionType  : Type of permissions the user/role has on an object. Examples could include CONNECT, EXECUTE, SELECT
                  DELETE, INSERT, ALTER, CONTROL, TAKE OWNERSHIP, VIEW DEFINITION, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
PermissionState : Reflects the state of the permission type, examples could include GRANT, DENY, etc.
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ObjectType      : Type of object the user/role is assigned permissions on.  Examples could include USER_TABLE, 
                  SQL_SCALAR_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION, SQL_STORED_PROCEDURE, VIEW, etc.   
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.          
ObjectName      : Name of the object that the user/role is assigned permissions on.  
                  This value may not be populated for all roles.  Some built in roles have implicit permission
                  definitions.
ColumnName      : Name of the column of the object that the user/role is assigned permissions on. This value
                  is only populated if the object is a table, view or a table value function.                 
*/

--List all access provisioned to a sql user or windows user/group directly 
SELECT  
    [UserName] = CASE princ.[type] 
                    WHEN 'S' THEN princ.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE princ.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,  
    [DatabaseUserName] = princ.[name],       
    [Role] = null,      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],       
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --database user
    sys.database_principals princ  
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col ON col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE 
    princ.[type] in ('S','U')
UNION
--List all access provisioned to a sql user or windows user/group through a database or application role
SELECT  
    [UserName] = CASE memberprinc.[type] 
                    WHEN 'S' THEN memberprinc.[name]
                    WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE memberprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END, 
    [DatabaseUserName] = memberprinc.[name],   
    [Role] = roleprinc.[name],      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],   
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --Role/member associations
    sys.database_role_members members
JOIN
    --Roles
    sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN
    --Role members (database users)
    sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col on col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
UNION
--List all access provisioned to the public role, which everyone gets by default
SELECT  
    [UserName] = '{All Users}',
    [UserType] = '{All Users}', 
    [DatabaseUserName] = '{All Users}',       
    [Role] = roleprinc.[name],      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],  
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --Roles
    sys.database_principals roleprinc
LEFT JOIN        
    --Role permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col on col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]                   
JOIN 
    --All objects   
    sys.objects obj ON obj.[object_id] = perm.[major_id]
WHERE
    --Only roles
    roleprinc.[type] = 'R' AND
    --Only public role
    roleprinc.[name] = 'public' AND
    --Only objects of ours, not the MS objects
    obj.is_ms_shipped = 0
ORDER BY
    princ.[Name],
    OBJECT_NAME(perm.major_id),
    col.[name],
    perm.[permission_name],
    perm.[state_desc],
    obj.type_desc--perm.[class_desc] 
  



--https://blogs.msdn.microsoft.com/sqlsecurity/2011/08/25/database-engine-permission-basics/
--To return the explicit permissions granted or denied in a database, execute the following statement in the database.

SELECT 
perms.state_desc AS State, 
permission_name AS [Permission], 
obj.name AS [on Object], 
dPrinc.name AS [to User Name], 
sPrinc.name AS [who is Login Name]
FROM sys.database_permissions AS perms
JOIN sys.database_principals AS dPrinc
ON perms.grantee_principal_id = dPrinc.principal_id
JOIN sys.objects AS obj
ON perms.major_id = obj.object_id
LEFT OUTER JOIN sys.server_principals AS sPrinc
ON dPrinc.sid = sPrinc.sid

--To return the members of the server roles, execute the following statement.

SELECT sRole.name AS [Server Role Name] , sPrinc.name AS [Members]
FROM sys.server_role_members AS sRo
JOIN sys.server_principals AS sPrinc
ON sRo.member_principal_id = sPrinc.principal_id
JOIN sys.server_principals AS sRole
ON sRo.role_principal_id = sRole.principal_id;

--To return the members of the database roles, execute the following statement in the database.

SELECT dRole.name AS [Database Role Name], dPrinc.name AS [Members]
FROM sys.database_role_members AS dRo
JOIN sys.database_principals AS dPrinc
ON dRo.member_principal_id = dPrinc.principal_id
JOIN sys.database_principals AS dRole
ON dRo.role_principal_id = dRole.principal_id;
    