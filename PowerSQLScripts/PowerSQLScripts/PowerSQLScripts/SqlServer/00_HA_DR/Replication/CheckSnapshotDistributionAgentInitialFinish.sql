-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/04/20
-- Description:	Check if Snapshot and Distribution Agent Initial Finish

-- =============================================

--set transaction isolation level read uncommitted

select COUNT(*)
  FROM [distribution].[dbo].[MSsnapshot_history]hist
  join [distribution].[dbo].[MSsnapshot_agents] ag
  on hist.agent_id = ag.id
  where [time] > '2018-04-20 14:43:00.000' and comments like '%a snapshot of%'
  
SELECT TOP 1000 [agent_id]
	,ag.name
      ,[runstatus]
      ,[start_time]
      ,[time]
      ,[duration]
      ,[comments]
      ,[delivered_transactions]
      ,[delivered_commands]
      ,[delivery_rate]
      ,[error_id]
      ,[timestamp]
  FROM [distribution].[dbo].[MSsnapshot_history]hist
  join [distribution].[dbo].[MSsnapshot_agents] ag
  on hist.agent_id = ag.id
  where [time] > '2018-04-20 14:43:00.000' and comments like '%a snapshot of%'
  order by [time] 
  
  
SELECT COUNT(*)
  FROM [distribution].[dbo].[MSdistribution_history] hist
  join [distribution].[dbo].[MSdistribution_agents] ag
  on hist.agent_id = ag.id
  where [time] > '2018-04-20 14:43:00.000'
  AND [comments] like '%Delivered snapshot from the%'
  
SELECT TOP 1000 [agent_id]
,ag.name
      ,[runstatus]
      ,[start_time]
      ,[time]
      ,[duration]
      ,[comments]
      ,[xact_seqno]
      ,[current_delivery_rate]
      ,[current_delivery_latency]
      ,[delivered_transactions]
      ,[delivered_commands]
      ,[average_commands]
      ,[delivery_rate]
      ,[delivery_latency]
      ,[total_delivered_commands]
      ,[error_id]
      ,[updateable_row]
      ,[timestamp]
  FROM [distribution].[dbo].[MSdistribution_history] hist
  join [distribution].[dbo].[MSdistribution_agents] ag
  on hist.agent_id = ag.id
  where [time] > '2018-04-20 14:43:00.000'
  AND [comments] like '%Delivered snapshot from the%'
  order by [time] 