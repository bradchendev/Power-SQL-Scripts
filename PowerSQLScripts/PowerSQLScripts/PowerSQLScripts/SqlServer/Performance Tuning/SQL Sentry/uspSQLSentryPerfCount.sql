-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/04/24
-- Description:	  SQL Sentry (Third-Party) - Query SQL Sentry Performance Log Collection history for CPU Usage
-- 
-- =============================================
USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspSQLSentryPerfCount]    Script Date: 05/08/2018 13:15:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






----------------------------------------------------
-- Create By Brad Chen
-- @CPU_Core int : CPU Core number
-- @DeviceId int : 主機ID. ex. 1 for TPECDB08
-- @PerformanceAnalysisCounterID int : ex. 71 for Processor Time %
-- @startTime datetime : Log time 
-- @endTime datetime : Log time
-- 
-- sample query
--DECLARE @CollectDate nvarchar(10) = '2018-04-25'

---- @PerformanceAnalysisCounterID
---- 71 -- PROCESS	PERCENT_PROCESSOR_TIME
---- 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
---- 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC

--DECLARE @sql nvarchar(1500)
--SET @sql = N'
--select startTime, endTime, [Week], [Avg] as [Avg CPU %],[Min] as [Min CPU %],[Max] as [Max CPU %] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, 1, 71, ''''' + @CollectDate + ' 22:30:00'''', ''''' + @CollectDate + ' 22:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg] as [Avg CPU %],[Min] as [Min CPU %],[Max] as [Max CPU %] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, 1, 71, ''''' + @CollectDate + ' 21:30:00'''', ''''' + @CollectDate + ' 21:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg] as [Avg CPU %],[Min] as [Min CPU %],[Max] as [Max CPU %] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, 1, 71, ''''' + @CollectDate + ' 20:30:00'''', ''''' + @CollectDate + ' 20:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg] as [Avg CPU %],[Min] as [Min CPU %],[Max] as [Max CPU %] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, 1, 71, ''''' + @CollectDate + ' 19:30:00'''', ''''' + @CollectDate + ' 19:33:00'''''')
--'
--EXEC(@sql);


--SET @sql = N'
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 185, ''''' + @CollectDate + ' 22:30:00'''', ''''' + @CollectDate + ' 22:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 185, ''''' + @CollectDate + ' 21:30:00'''', ''''' + @CollectDate + ' 21:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 185, ''''' + @CollectDate + ' 20:30:00'''', ''''' + @CollectDate + ' 20:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 185, ''''' + @CollectDate + ' 19:30:00'''', ''''' + @CollectDate + ' 19:33:00'''''')
--'
--EXEC(@sql);

--SET @sql = N'
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 212, ''''' + @CollectDate + ' 22:30:00'''', ''''' + @CollectDate + ' 22:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 212, ''''' + @CollectDate + ' 21:30:00'''', ''''' + @CollectDate + ' 21:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 1, 1, 212, ''''' + @CollectDate + ' 20:30:00'''', ''''' + @CollectDate + ' 20:33:00'''''')
--UNION ALL
--select startTime, endTime, [Week], [Avg], [Min], [Max] FROM     OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, 1, 185, ''''' + @CollectDate + ' 19:30:00'''', ''''' + @CollectDate + ' 19:33:00'''''')
--'
--EXEC(@sql);
----------------------------------------------------
CREATE PROC [dbo].[uspSQLSentryPerfCount](@CPU_Core int, @DeviceId int, @PerformanceAnalysisCounterID int, @startTime datetime, @endTime datetime)  
AS  
BEGIN  
 SET NOCOUNT ON; 
DECLARE @now datetime = GETDATE();
--DECLARE @now_utc datetime =  DATEADD(HOUR,-8,@now);

DECLARE @startTime_utc datetime, @endTime_utc datetime;
SET @startTime_utc = DATEADD(HOUR,-8,@startTime);
SET @endTime_utc = DATEADD(HOUR,-8,@endTime);

DECLARE @sql nvarchar(1500);

DECLARE @SentryPerfCount  TABLE
(
[StartTime] datetime,
[endTime] datetime,
[weekday] int,
[Week] nvarchar(10),
 [Avg] int,
 [Min] int,
  [Max] int
);



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
	WITH cte 
	AS 
	( 
	select 
	DATEADD(HOUR,+8,SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time UTC plus 8], '
	+ @ComputedValue + 
	'from ' + @TableName + N'  
	where 
	DeviceID = ' + CAST(@DeviceId as nvarchar) + ' 
	and PerformanceAnalysisCounterID = ' + CAST(@PerformanceAnalysisCounterID as nvarchar) + '  
	and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(''' + CONVERT(nvarchar(23), @startTime_utc, 120) + N''') 
	and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(''' + CONVERT(nvarchar(23), @endTime_utc, 120) + N''') 
	) 
		select 
		CONVERT(nvarchar(23), ''' + CONVERT(nvarchar(23), @startTime, 120) + N''', 120) as [StartTime] , 
		CONVERT(nvarchar(23), ''' + CONVERT(nvarchar(23), @endTime, 120) + N''', 120) as [endTime] , 
		DATEPART(weekday, ''' + CONVERT(nvarchar(23), @startTime, 120) + N''') as [weekday],
		CASE DATEPART(weekday, ''' + CONVERT(nvarchar(23), @endTime, 120) + N''') 
			when 1 then N''日'' 
			when 2 then N''一''
			when 3 then N''二''
			when 4 then N''三''
			when 5 then N''四''
			when 6 then N''五''
			when 7 then N''六''
		end as [Week],
		AVG([Value]) as [Avg],
		MIN([Value]) as [Min],
		MAX([Value]) as [Max] from cte;'
	insert @SentryPerfCount EXEC(@sql);
	--PRINT @sql
	SELECT * from @SentryPerfCount;
    RETURN
END;



GO


