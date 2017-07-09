-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Replication Agent and Latence

-- =============================================

select * from msdb.dbo.MSagent_profiles
-- [type]
-- 0 = System
-- 1 = Custom

-- [agent_type]
 --1 = Snapshot Agent
 --2 = Log Reader Agent
 --3 = Distribution Agent
 --4 = Merge Agent
 --9 = Queue Reader Agent

select * from msdb.dbo.MSagent_parameters


-- Show profile parameter
exec sp_help_agent_parameter @profile_id = 4



-- 降低同步延遲
-- 調整log reader與distribution agent
-- 調整Pooling Interval將 5 sec改為 1 sec


-- 若有網路環境問題，拉長LoginTimeout = 60

--declare @config_id int
--exec sp_add_agent_profile @profile_id = @config_id OUTPUT, @profile_name = N'AddTimeout', @agent_type = 3, @profile_type  = 1, @description = N''
--select @config_id
--go
--exec sp_help_agent_profile @profile_id = 18
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-BcpBatchSize', @parameter_value = N'2147473647'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-CommitBatchSize', @parameter_value = N'100'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-CommitBatchThreshold', @parameter_value = N'1000'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-HistoryVerboseLevel', @parameter_value = N'1'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-KeepAliveMessageInterval', @parameter_value = N'300'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-LoginTimeout', @parameter_value = N'60'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-MaxBcpThreads', @parameter_value = N'1'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-MaxDeliveredTransactions', @parameter_value = N'0'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-PollingInterval', @parameter_value = N'5'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-QueryTimeout', @parameter_value = N'1800'
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-SkipErrors', @parameter_value = N''
--go
--use [master]
--exec sp_change_agent_parameter @profile_id = 18, @parameter_name = N'-TransactionsPerHistory', @parameter_value = N'100'
--go


--exec sp_help_agent_profile @profile_id = 18



--sp_update_agent_profile (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188922.aspx
--@agent_type
--Value	Description
--1	Snapshot Agent.
--2	Log Reader Agent.
--3	Distribution Agent.
--4	Merge Agent.
--9	Queue Reader Agent.

--use [master]
--exec [distribution].dbo.sp_update_agent_profile @agent_type = 3, @agent_id = 2, @profile_id = 18

--exec sp_help_agent_profile @agent_type = 3

