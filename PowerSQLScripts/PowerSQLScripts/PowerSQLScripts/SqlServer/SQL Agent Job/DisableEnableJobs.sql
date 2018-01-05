-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/11/30
-- Description:	Disable or Enable All Jobs

-- =============================================

SELECT [name], [enabled] from msdb.dbo.sysjobs


SELECT 
'EXEC dbo.sp_update_job @job_name = N''' + 
[name] +
''', @enabled = 0'
from msdb.dbo.sysjobs
where [enabled] = 1
