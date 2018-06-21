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

/****** Object:  StoredProcedure [dbo].[uspCollectSQLSentryPerfCountAgg]    Script Date: 05/08/2018 13:12:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--EXEC [uspCollectSQLSentryPerfCountAgg]

-- Create by Brad Chen
CREATE PROC [dbo].[uspCollectSQLSentryPerfCountAgg]
AS
--DECLARE @CollectDate nvarchar(10) = '2018-04-01';
DECLARE @CollectDate nvarchar(10) = CAST( GETDATE() AS DATE);
DECLARE @DbServer nvarchar(10) = 'TPECDB08';
DECLARE @DbServerId nvarchar(10) = '1';

DECLARE @PerfCountId nvarchar(5);

-- 因為是收集4次(19半,20半,21半,22半)的平均，所以，超過22:33才收集
if (datepart(hh, GETDATE()) >= 22 and datepart(mi, GETDATE()) >= 35)
BEGIN
DECLARE @WeekDay nchar(1) 
SELECT @WeekDay = CASE DATEPART(weekday, @CollectDate)
		when 1 then N'日'
			when 2 then N'一'
			when 3 then N'二'
			when 4 then N'三'
			when 5 then N'四'
			when 6 then N'五'
			when 7 then N'六' end;
--select @WeekDay;

DECLARE @sql nvarchar(1500)

-- 71 PROCESS	PERCENT_PROCESSOR_TIME
SET @PerfCountId = '71';
SET @sql = N'
WITH cte
AS
(
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 22:30:00'''', ''''' + @CollectDate + N' 22:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 21:30:00'''', ''''' + @CollectDate + N' 21:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 20:30:00'''', ''''' + @CollectDate + N' 20:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 19:30:00'''', ''''' + @CollectDate + N' 19:33:00'''''')
)
SELECT 
N''' +@CollectDate + N''' as [SentryLogDate]
,N''' +@WeekDay + N''' as [WeekDay]
,N''' +@DbServer + N''' as [DbServer]
, '+ @PerfCountId + N' as [PerfCountId]
,Min([Min])
,Max([Max])
,Avg([Avg])
from cte;
'
--PRINT @sql
INSERT INTO DBA.dbo.SQLSentryCpuUsgAggHist( 
	[SentryLogDate]
      ,[WeekDay]
      ,[DbServer]
      ,[PerfCountId]
      ,[Min]
      ,[Max]
      ,[Avg])
EXEC(@sql);




-- 185 SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
SET @PerfCountId = '185';
SET @sql = N'
WITH cte
AS
(
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 22:30:00'''', ''''' + @CollectDate + N' 22:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 21:30:00'''', ''''' + @CollectDate + N' 21:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 20:30:00'''', ''''' + @CollectDate + N' 20:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 19:30:00'''', ''''' + @CollectDate + N' 19:33:00'''''')
)
SELECT 
N''' +@CollectDate + N''' as [SentryLogDate]
,N''' +@WeekDay + N''' as [WeekDay]
,N''' +@DbServer + N''' as [DbServer]
, '+ @PerfCountId + N' as [PerfCountId]
,Min([Min])
,Max([Max])
,Avg([Avg])
from cte;
'
--PRINT @sql
INSERT INTO DBA.dbo.SQLSentryCpuUsgAggHist( 
	[SentryLogDate]
      ,[WeekDay]
      ,[DbServer]
      ,[PerfCountId]
      ,[Min]
      ,[Max]
      ,[Avg])
EXEC(@sql);



-- 212 SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
SET @PerfCountId = '212';
SET @sql = N'
WITH cte
AS
(
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 22:30:00'''', ''''' + @CollectDate + N' 22:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 21:30:00'''', ''''' + @CollectDate + N' 21:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 20:30:00'''', ''''' + @CollectDate + N' 20:33:00'''''')
UNION ALL
select startTime, endTime, [Week], [Avg], [Min], [Max] FROM    OPENQUERY(LOCAL2, ''exec DBA.dbo.uspSQLSentryPerfCount 60, ' + @DbServerId + N', ' + @PerfCountId + N', ''''' + @CollectDate + N' 19:30:00'''', ''''' + @CollectDate + N' 19:33:00'''''')
)
SELECT 
N''' +@CollectDate + N''' as [SentryLogDate]
,N''' +@WeekDay + N''' as [WeekDay]
,N''' +@DbServer + N''' as [DbServer]
, '+ @PerfCountId + N' as [PerfCountId]
,Min([Min])
,Max([Max])
,Avg([Avg])
from cte;
'
--PRINT @sql
INSERT INTO DBA.dbo.SQLSentryCpuUsgAggHist( 
	[SentryLogDate]
      ,[WeekDay]
      ,[DbServer]
      ,[PerfCountId]
      ,[Min]
      ,[Max]
      ,[Avg])
EXEC(@sql);

PRINT 'Collection Success'

END
ELSE
BEGIN
	PRINT 'Not Collection Time'
	
	PRINT N'GETDATE(): '+ CONVERT(nvarchar(23), GETDATE(), 121)
	PRINT N'Hour: '+ cast(datepart(hh, GETDATE())  as nvarchar)
	PRINT N'Minute: '+ cast(datepart(mm, GETDATE())  as nvarchar)
	
END



GO


