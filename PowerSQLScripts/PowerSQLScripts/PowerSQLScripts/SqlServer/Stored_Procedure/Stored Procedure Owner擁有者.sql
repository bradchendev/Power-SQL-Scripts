-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Stored Procedure Owner擁有者

-- =============================================



exec sp_executesql N'SELECT
sp.name AS [Name],
sp.object_id AS [ID],
sp.create_date AS [CreateDate],
sp.modify_date AS [DateLastModified],
ISNULL(ssp.name, N'''') AS [Owner],
CAST(case when sp.principal_id is null then 1 else 0 end AS bit) AS [IsSchemaOwned],
SCHEMA_NAME(sp.schema_id) AS [Schema],
CAST(
 case 
    when sp.is_ms_shipped = 1 then 1
    when (
        select 
            major_id 
        from 
            sys.extended_properties 
        where 
            major_id = sp.object_id and 
            minor_id = 0 and 
            class = 1 and 
            name = N''microsoft_database_tools_support'') 
        is not null then 1
    else 0
end          
             AS bit) AS [IsSystemObject],
CAST(OBJECTPROPERTYEX(sp.object_id,N''ExecIsAnsiNullsOn'') AS bit) AS [AnsiNullsStatus],
CAST(OBJECTPROPERTYEX(sp.object_id,N''ExecIsQuotedIdentOn'') AS bit) AS [QuotedIdentifierStatus],
CAST(CASE WHEN ISNULL(smsp.definition, ssmsp.definition) IS NULL THEN 1 ELSE 0 END AS bit) AS [IsEncrypted],
CAST(ISNULL(smsp.is_recompiled, ssmsp.is_recompiled) AS bit) AS [Recompile],
case when amsp.object_id is null then N'''' else asmblsp.name end AS [AssemblyName],
case when amsp.object_id is null then N'''' else amsp.assembly_class end AS [ClassName],
case when amsp.object_id is null then N'''' else amsp.assembly_method end AS [MethodName],
case when amsp.object_id is null then case isnull(smsp.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end else case isnull(amsp.execute_as_principal_id, -1) when -1 then 1 when -2 then 2 else 3 end end AS [ExecutionContext],
case when amsp.object_id is null then ISNULL(user_name(smsp.execute_as_principal_id),N'''') else user_name(amsp.execute_as_principal_id) end AS [ExecutionContextPrincipal],
CAST(ISNULL(spp.is_auto_executed,0) AS bit) AS [Startup],
CAST(CASE sp.type WHEN N''RF'' THEN 1 ELSE 0 END AS bit) AS [ForReplication],
CASE WHEN sp.type = N''P'' THEN 1 WHEN sp.type = N''PC'' THEN 2 ELSE 1 END AS [ImplementationType]
FROM
sys.all_objects AS sp
LEFT OUTER JOIN sys.database_principals AS ssp ON ssp.principal_id = ISNULL(sp.principal_id, (OBJECTPROPERTY(sp.object_id, ''OwnerId'')))
LEFT OUTER JOIN sys.sql_modules AS smsp ON smsp.object_id = sp.object_id
LEFT OUTER JOIN sys.system_sql_modules AS ssmsp ON ssmsp.object_id = sp.object_id
LEFT OUTER JOIN sys.assembly_modules AS amsp ON amsp.object_id = sp.object_id
LEFT OUTER JOIN sys.assemblies AS asmblsp ON asmblsp.assembly_id = amsp.assembly_id
LEFT OUTER JOIN sys.procedures AS spp ON spp.object_id = sp.object_id
WHERE
(sp.type = @_msparam_0 OR sp.type = @_msparam_1 OR sp.type=@_msparam_2)and(sp.name=@_msparam_3 and SCHEMA_NAME(sp.schema_id)=@_msparam_4)',N'@_msparam_0 nvarchar(4000),@_msparam_1 nvarchar(4000),@_msparam_2 nvarchar(4000),@_msparam_3 nvarchar(4000),@_msparam_4 nvarchar(4000)',@_msparam_0=N'P',@_msparam_1=N'RF',@_msparam_2=N'PC',@_msparam_3=N'uspGetEmployeeManagers',@_msparam_4=N'dbo'
