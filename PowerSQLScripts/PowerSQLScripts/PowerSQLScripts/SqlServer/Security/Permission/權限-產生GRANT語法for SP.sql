
USE AdventureWorks2008R2;
select 'grant execute on [' + SCHEMA_NAME(schema_id) + '].[' + [name] + '] to AppUser1;' from sys.procedures
where [name] like 'uspGetEmployee%'


--grant execute on [dbo].[uspGetEmployeeManagers] to AppUser1;
