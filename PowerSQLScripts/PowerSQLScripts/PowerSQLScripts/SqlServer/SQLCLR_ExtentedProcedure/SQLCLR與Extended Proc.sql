-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	SQLCLR and Extended Procedure

-- =============================================


-- Memory to Leave
--MTL (Memory to Leave)= (Stack size * max worker threads) + Additional space (By default 256 MB and can be controlled by -g). 
--Stack size =512 KB per thread for 32 Bit SQL Server 
--I.e = (256 *512 KB) + 256MB =384MB


-- max worker threads https://msdn.microsoft.com/en-us/library/ms190219.aspx
-- Number of CPUs	32-bit computer	64-bit computer
-- <= 4 processors	256	512
-- 8 processors	288	576
--16 processors	352	704



--  以下查詢到的比較接近 -g 所指定的大小
WITH VAS_Summary AS
(
    SELECT Size = VAS_Dump.Size,
    Reserved = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 0 ELSE 1 END),
    Free = SUM(CASE(CONVERT(INT, VAS_Dump.Base) ^ 0) WHEN 0 THEN 1 ELSE 0 END)
    FROM
    (
        SELECT CONVERT(VARBINARY, SUM(region_size_in_bytes)) [Size],
            region_allocation_base_address [Base]
            FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address <> 0
        GROUP BY region_allocation_base_address
        UNION
        SELECT
            CONVERT(VARBINARY, region_size_in_bytes) [Size],
            region_allocation_base_address [Base]
        FROM sys.dm_os_virtual_address_dump
        WHERE region_allocation_base_address = 0x0 ) AS VAS_Dump
        GROUP BY Size
    )
SELECT
    SUM(CONVERT(BIGINT, Size) * Free) / 1024 AS [Total avail mem, KB],
    CAST(MAX(Size) AS BIGINT) / 1024 AS [Max free size, KB]
FROM VAS_Summary WHERE FREE <> 0


-- Memory to Leave
-- https://blogs.msdn.microsoft.com/karthick_pk/2013/03/16/sql-server-memory-internals/



select * from sys.dm_clr_appdomains

select appdomain_id, creation_time, db_id, user_id, state  
from sys.dm_clr_appdomains a  
where appdomain_address =   
(select appdomain_address   
 from sys.dm_clr_loaded_assemblies  
   where assembly_id = 500); 
   
  
select a.name, a.assembly_id, a.permission_set_desc, a.is_visible, a.create_date, l.load_time   
from sys.dm_clr_loaded_assemblies as l   
inner join sys.assemblies as a  
on l.assembly_id = a.assembly_id  
where l.appdomain_address =   
(select appdomain_address   
from sys.dm_clr_appdomains  
where appdomain_id = 15);    


-- find stored procedure of user-defined function use SQLCLR
select * from sys.assembly_modules
--object_id   assembly_id assembly_class                          assembly_method             null_on_null_input execute_as_principal_id
------------- ----------- --------------------------------------------------- -------------------------------------- ------------------ -----------------------
--226972035   65536       Fn_Unicode.fn_unicode            Fn_Unicode              0                  NULL

-- 找出find stored procedure of user-defined function
select * from sys.objects
where [object_id] = 226972035



SELECT 
    assembly = a.name, 
    path     = f.name
FROM sys.assemblies AS a
INNER JOIN sys.assembly_files AS f
ON a.assembly_id = f.assembly_id



-- SQLCLR
SELECT * FROM sys.assembly_modules;
SELECT * FROM sys.assembly_files;

-- which db use SQLCLR
USE [master]
GO
EXEC sp_MSforeachdb
'USE [?]
If (select count(*) from sys.assembly_files) > 1
BEGIN
print ":CLR = " + DB_NAME()
END'
GO


--Getting Started with CLR Integration
--https://msdn.microsoft.com/en-us/library/ms131052.aspx
--How to: Create and Run a SQL Server User-Defined Function by using Common Language Run-time Integration
--https://msdn.microsoft.com/en-us/library/w2kae45k.aspx
--How to: Create and Run a SQL Server Stored Procedure by using Common Language Run-time Integration
--https://msdn.microsoft.com/en-us/library/5czye81z.aspx


--Introduction to SQL Server CLR Integration
--https://msdn.microsoft.com/en-us/library/ms254498(v=vs.110).aspx


-- Extended stored procedure
EXEC sp_helpextendedproc;



