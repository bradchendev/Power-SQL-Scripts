-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Search KeyWord in SP

-- =============================================

-- Search SP Definition and return result list
declare @SearchKeyWord nvarchar(2000);
set @SearchKeyWord = 'testdb';
--set @SearchKeyWord = '[[]testdb]';

declare @sqlcmd nvarchar(max);
 
set @sqlcmd = 
'
use [?];
select ''' + @SearchKeyWord + ''' ,db_name() as databasename, sm.object_id, o.name as objectname, o.type as obejcttype, sm.definition as sqlcommand
from sys.sql_modules as sm with (nolock)
left join sys.objects as o with (nolock) on sm.object_id = o.object_id
where sm.definition like ''%' + @SearchKeyWord + '%'' 
';
exec sp_MSForEachDb @sqlcmd;



-- Search SP Definition and Insert result into temp Table
create table ##tmpCheckStringInSP
(
	databasename sysname not null,
	object_id int not null,
	objectname sysname null,
	objecttype sysname null,
	sqlcommand nvarchar(max)
);
declare @SearchKeyWord nvarchar(max);
set @SearchKeyWord = 'testdb';
declare @sqlcmd nvarchar(max);
set @sqlcmd = 
'
use [?];
insert into ##tmpCheckStringInSP (databasename, object_id, objectname, objecttype, sqlcommand)
select db_name() as databasename, sm.object_id, o.name as objectname, o.type as obejcttype, sm.definition as sqlcommand
from sys.sql_modules as sm with (nolock)
left join sys.objects as o with (nolock) on sm.object_id = o.object_id
where sm.definition like ''%' + @SearchKeyWord + '%'' 
';
exec sp_MSForEachDb @sqlcmd;
select * from ##tmpCheckStringInSP order by databasename, objecttype;
drop table ##tmpCheckStringInSP;