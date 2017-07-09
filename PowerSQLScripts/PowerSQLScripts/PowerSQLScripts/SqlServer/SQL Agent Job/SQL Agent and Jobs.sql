-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	SQL Agent and Jobs.sql

-- =============================================

-- Job List
select * from msdb.dbo.sysjobs_view

-- 查詢 Step裡面有設定字串
select 
(select name from msdb.dbo.sysjobs where job_id = jstep.job_id)
,jstep.* from msdb.dbo.sysjobsteps as jstep
where jstep.command like '%uspGetManager%'


