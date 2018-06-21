	-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/04/30
-- Description:	  SQL Sentry (Third-Party) - Query SQL Sentry Performance Log Collection history for CPU Usage by Datetime Range
-- 
-- =============================================

USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspGetSQLSentryPerfCountByDatetime]    Script Date: 05/08/2018 14:27:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	
-- Create by Brad Chen
	-- @PerformanceAnalysisCounterID
	-- 71 PROCESS	PERCENT_PROCESSOR_TIME
	-- 185 SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
	-- 212 SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC

-- EXEC dbo.uspGetSQLSentryPerfCountByDatetime 60, 1, 71, '2018-04-30 10:40:00', '2018-04-30 14:10:00'


CREATE PROC [dbo].[uspGetSQLSentryPerfCountByDatetime]
	@CPU_Core int, 
	@DeviceId int, 
	@PerformanceAnalysisCounterID int, 
	@startTime datetime, 
	@endTime datetime
AS
BEGIN
	SET NOCOUNT ON; 
	DECLARE @now datetime = GETDATE();
	--DECLARE @now_utc datetime =  DATEADD(HOUR,-8,@now);

	DECLARE @startTime_utc datetime, @endTime_utc datetime;
	SET @startTime_utc = DATEADD(HOUR,-8,@startTime);
	SET @endTime_utc = DATEADD(HOUR,-8,@endTime);

	DECLARE @sql nvarchar(1500);

	-- Counter Type
	DECLARE @ComputedValue nvarchar(50);
	IF @PerformanceAnalysisCounterID = 71 
		SET @ComputedValue = 'CAST([value] as int)/' + CAST(@CPU_Core as nvarchar) + ' as [Value] '
	ELSE
		SET @ComputedValue = 'CAST([value] as int) as [Value] '
		
	-- Source Table
	DECLARE @TableName nvarchar(100);
	IF DATEDIFF(MINUTE,@endTime,@now) < 4320
	BEGIN
		SET @TableName = N'[SQLSentry].[dbo].[PerformanceAnalysisData]';
	END;
	ELSE
	BEGIN
		SET @TableName = N'[PerformanceMonitor].[SQLSentry].[PerformanceAnalysisData' + convert(nvarchar(6), @endTime, 112) + N']';
	END;
	

	SET @sql = N'
	select 
	DATEADD(HOUR,+8,SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time UTC plus 8], '
	+ @ComputedValue + 
	'from ' + @TableName + N'  
	where 
	DeviceID = ' + CAST(@DeviceId as nvarchar) + ' 
	and PerformanceAnalysisCounterID = ' + CAST(@PerformanceAnalysisCounterID as nvarchar) + '  
	and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(''' + CONVERT(nvarchar(23), @startTime_utc, 120) + N''') 
	and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(''' + CONVERT(nvarchar(23), @endTime_utc, 120) + N''') 
	';
		
	EXEC(@sql);

END


GO


