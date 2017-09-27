-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/9/27
-- Description:	query Log Reader agent history for latency monitoring

-- =============================================

USE [DBA]
GO
-- Create by: Brad Chen
-- Create Date: 2017/9/27
-- 從MSlogreader_history表，取得每5分鐘處理的交易數量與command數量
-- exec dbo.usp_getLogReaderProcessHistory @agent_id = 2, @startime = '2017-04-28 07:00:00.000', @endTime = '2017-04-28 10:00:00.000'
CREATE procedure [dbo].[usp_getLogReaderProcessHistory]
@startime datetime
,@endTime datetime
,@agent_id int
AS
;WITH MSlogreader_history_withRowNumber ([RowNumber], [agent_id], [time], [delivered_transactions], [delivered_commands])
AS
(
  SELECT ROW_NUMBER() OVER (ORDER BY [time] DESC) RowNumber
  ,[agent_id]
  ,[time]
  ,[delivered_transactions]
  ,[delivered_commands]
  FROM [distribution].[dbo].[MSlogreader_history]
  where 
	agent_id = @agent_id
	and 
	[time] between @startime and @endTime 
)
SELECT 
a.[agent_id]
,a.[time]
,DATEDIFF(second,b.[time],a.[time]) as [TimeDiff_with_lastTime (sec)]
,a.[delivered_transactions] - b.[delivered_transactions] as [diff_with_lastTime_transactions]
,a.[delivered_commands] - b.[delivered_commands] as [diff_with_lastTime_commands]
FROM MSlogreader_history_withRowNumber a
JOIN MSlogreader_history_withRowNumber b
ON a.RowNumber = b.RowNumber-1

GO


