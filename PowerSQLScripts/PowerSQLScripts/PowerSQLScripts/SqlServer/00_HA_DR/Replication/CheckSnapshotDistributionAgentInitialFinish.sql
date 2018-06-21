-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/04/23
-- Description:	Check if Snapshot and Distribution Agent Initial Finish

-- =============================================

--set transaction isolation level read uncommitted

DECLARE @Repl_Initial_Starttime datetime = '2018-04-23 15:00:00.000'


-- Snapshot Agent
select COUNT(*) as [Finished]
  FROM [distribution].[dbo].[MSsnapshot_history]hist 
  join [distribution].[dbo].[MSsnapshot_agents] ag
  on hist.agent_id = ag.id
  where [time] > @Repl_Initial_Starttime 
  and
    ( 
  comments like '%a snapshot of%'
  or
  comments like '%A snapshot was not generated because no subscriptions needed initialization%'
  )

--SELECT TOP 1000 [agent_id]
--	,ag.name
--      ,[runstatus]
--      ,[start_time]
--      ,[time]
--      ,[duration]
--      ,[comments]
--      ,[delivered_transactions]
--      ,[delivered_commands]
--      ,[delivery_rate]
--      ,[error_id]
--      ,[timestamp]
--  FROM [distribution].[dbo].[MSsnapshot_history] hist
--  join [distribution].[dbo].[MSsnapshot_agents] ag
--  on hist.agent_id = ag.id
--  where [time] > '2018-04-23 11:30:00.000' and comments like '%a snapshot of%'
--  order by [time] 
  --  select 
		--*
  --FROM [distribution].[dbo].[MSsnapshot_history]
  --where [time] > '2018-04-23 14:10:00.000' 
  --and comments like '[[]%'
  
select 
CASE  
when ([comments] like '%a snapshot of%') then N'完成'
when ([comments] like '%A snapshot was not generated because no subscriptions needed initialization%') then N'完成'
else N'進行中' 
end as [Status]
,SUBSTRING([comments],CHARINDEX('[',[comments])+1 ,CHARINDEX(']',[comments])-CHARINDEX('[',[comments])-1) 
 as [BcpOutPercent]
,ag.name,* from [distribution].[dbo].[MSsnapshot_history] as hist 
inner join 
(
  select 
		agent_id
		,MAX([time]) as maxTime
  FROM [distribution].[dbo].[MSsnapshot_history]
  where [time] > @Repl_Initial_Starttime 
  and ( comments like '[[]%' or [comments] like '%a snapshot of%')
  group by agent_id
) histGy
on hist.agent_id = histGy.agent_id and hist.[time] = histGy.maxTime
-- and  [comments] like '%a snapshot of%'
inner join [distribution].[dbo].[MSsnapshot_agents] ag
on hist.agent_id = ag.id 
order by [time] 
  

-- Distribution Agent
SELECT COUNT(*) as [Finished]
  FROM [distribution].[dbo].[MSdistribution_history] hist
  join [distribution].[dbo].[MSdistribution_agents] ag
  on hist.agent_id = ag.id
  where [time] > @Repl_Initial_Starttime
  AND [comments] like '%Delivered snapshot from the%'
  
--SELECT TOP 1000 [agent_id]
--,ag.name
--      ,[runstatus]
--      ,[start_time]
--      ,[time]
--      ,[duration]
--      ,[comments]
--      ,[xact_seqno]
--      ,[current_delivery_rate]
--      ,[current_delivery_latency]
--      ,[delivered_transactions]
--      ,[delivered_commands]
--      ,[average_commands]
--      ,[delivery_rate]
--      ,[delivery_latency]
--      ,[total_delivered_commands]
--      ,[error_id]
--      ,[updateable_row]
--      ,[timestamp]
--  FROM [distribution].[dbo].[MSdistribution_history] hist
--  join [distribution].[dbo].[MSdistribution_agents] ag
--  on hist.agent_id = ag.id 
--  where [time] > '2018-04-23 11:30:00.000'
--  AND [comments] like '%Delivered snapshot from the%'
--  order by [time] 
  

select 
CASE  
when (hist.[comments] like '%Delivered snapshot from the%') then N'完成'
when (hist.[comments] like '%stats state%') then N'完成'
when (hist.[comments] like '%Creating%') then N'完成'
else N'進行中' 
end as [Status]
,CASE WHEN CHARINDEX('(',hist.[comments]) > 0 then
 SUBSTRING([comments],CHARINDEX('(',[comments])+1 ,CHARINDEX(')',[comments])-CHARINDEX('(',[comments])-1) 
 else '' end
 as [BulkedRowCount Speed]
,ag.name,* from [distribution].[dbo].[MSdistribution_history] as hist 
inner join 
(
  select 
		agent_id
		,MAX([time]) as maxTime
  FROM [distribution].[dbo].[MSdistribution_history]
  where [time] > @Repl_Initial_Starttime 
  --and comments not in ('No replicated transactions are available.','Initializing')
  and ( comments like '%Applied script%' 
		or comments like '%bulk%' 
		or  comments like '%Creating%' 
		or [comments] like '%Delivered snapshot from the%')
  group by agent_id
) histGy
on hist.agent_id = histGy.agent_id and hist.[time] = histGy.maxTime
inner join [distribution].[dbo].[MSdistribution_agents] ag
on hist.agent_id = ag.id 
order by [time] 
  
  
  --select * FROM [distribution].[dbo].[MSdistribution_history]
  --where agent_id = 47
  --and time > = '2018-04-23 15:00:00.000'
  --order by [time]
  
  
  
  