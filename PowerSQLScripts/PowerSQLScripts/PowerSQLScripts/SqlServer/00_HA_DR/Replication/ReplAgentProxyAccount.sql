-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/05/18
-- Description:	Replication Agent執行帳戶

-- =============================================

-- proxy_id is null表示使用SQL Agent來執行
-- proxy_id is not null表示指定了一個Windows帳戶使用了proxy account


select job.name as [JobName],
cat.name as [Category],
step.step_name,
step.proxy_id,
pxy.name as [proxyNmae],
cred.credential_identity
 from msdb.dbo.sysjobs as job
inner join  msdb.dbo.sysjobsteps as step
on job.job_id = step.job_id
inner join [msdb].[dbo].[syscategories] as cat
on job.category_id = cat.category_id
and cat.name in ('REPL-Distribution','REPL-LogReader','REPL-Snapshot')
and step.step_name = 'Run agent.'
Left join msdb.dbo.sysproxies as pxy
on step.proxy_id = pxy.proxy_id
Left join [msdb].[sys].[credentials] as cred
on pxy.credential_id = cred.credential_id
--where step.proxy_id is not null
--and cat.name in ('REPL-Distribution')
--and job.name not like '%xxxxx%'
order by job.name, start_step_id
