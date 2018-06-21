-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	  SQL Sentry (Third-Party)
-- 
-- =============================================

-- 保留最新72 hour (3天)的紀錄，min=查詢當下的utc時間往前推3天
select 
max(SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp]))
, min(SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp])) 
from SQLSentry.dbo.PerformanceAnalysisData



--I Didn't Know it Could Do That! : Enabling Additional Performance Counters
--https://blogs.sentryone.com/justinrandall/didnt-know-5-performance-counters/

-- 列出所有counter
--SELECT  
--  pacc.CategoryResourceName AS Category,
--  pac.CounterResourceName AS Counter,
--pac.ID  
--FROM dbo.PerformanceAnalysisCounter AS pac
--INNER JOIN dbo.PerformanceAnalysisCounterCategory AS pacc
--  ON pac.PerformanceAnalysisCounterCategoryID = pacc.ID
--where pacc.CategoryResourceName like '%process%'  
--ORDER BY pacc.CategoryResourceName, pac.CounterResourceName
--;


-- 啟動counter必須指定interval，所以先查詢interval的可設定的選項值
--Valid values are defined in the PerformanceAnalysisSampleInterval table. This query returns the sample interval id, name, and collection interval value in seconds:

--SELECT 
--  ID,
--  Name,
--  IntervalInTicks/10000000 AS IntervalInSeconds
--FROM dbo.PerformanceAnalysisSampleInterval
--ORDER BY ID;



--First, we need the ID for this counter: 找出要啟用的counter
--SELECT 
--  ID, 
--  CounterResourceName 
--FROM dbo.PerformanceAnalysisCounter
--WHERE CounterResourceName = N'PAGE_SPLITS_PER_SEC';
 
---- Result:
--ID	CounterResourceName
--------  -------------------
--119	PAGE_SPLITS_PER_SEC


-- 檢查啟用狀態
--SELECT ID,CounterResourceName,PerformanceAnalysisSampleIntervalID
--from dbo.PerformanceAnalysisCounter 
--  WHERE PerformanceAnalysisCounter.ID = 119;
  
  --if PerformanceAnalysisSampleIntervalID = 0 表示沒有啟用
  

--Enabling this counter is simple: 啟用counter
---- CounterID = 119
--UPDATE dbo.PerformanceAnalysisCounter 
--  SET PerformanceAnalysisSampleIntervalID = 1 
--  WHERE PerformanceAnalysisCounter.ID = 119;

--I chose a sample interval of 10 seconds because page splits/sec is a volatile metric. For metrics that are less volatile, choose a different sample interval, using the PerformanceAnalysisSampleInterval as your guide.

--To start collecting this counter, restart your SQL Sentry Monitoring Service(s), then verify that collection is occurring by executing this query: 

--SELECT * 
--FROM dbo.PerformanceAnalysisData WITH (NOLOCK) 
--WHERE PerformanceAnalysisCounterID = 119; 
---- use the same CounterID as in your UPDATE statement


DECLARE @startTime_utc8 datetime 
DECLARE @endTime_utc8 datetime 

DECLARE @startTime_utc datetime 
DECLARE @endTime_utc datetime 

SET @startTime_utc8 = '2016-12-06 20:25:00'
SET @endTime_utc8 = '2016-12-06 20:35:00'

SET @startTime_utc = DATEADD(HOUR,-8,@startTime_utc8)
SET @endTime_utc = DATEADD(HOUR,-8,@endTime_utc8)

select 
DATEADD(HOUR,+8,SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time UTC+8],
SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp]) as [Time original UTC],
CAST([value] as int)/60 as [CPU %]
--*
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 71 -- PROCESS	PERCENT_PROCESSOR_TIME
and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(@startTime_utc)
and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(@endTime_utc);


WITH cte
AS
(
select 
DATEADD(HOUR,+8,SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time UTC plus 8],
--SQLSentry.dbo.fnConvertTimestampToDateTime([Timestamp]) as [Time original UTC],
CAST([value] as int)/60 as [CPU %]
--*
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 71 -- PROCESS	PERCENT_PROCESSOR_TIME
and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(@startTime_utc)
and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(@endTime_utc)
)
select 
AVG([CPU %]) as [Avg CPU %] 
, MAX([CPU %]) as [Max CPU %] from cte 
GO


--22點30~33分
-- add by brad
--DECLARE @outputmessage1 nvarchar(500), @outputmessage2 nvarchar(500), @outputmessage3 nvarchar(500)
DECLARE @startTime datetime 
DECLARE @endTime datetime 

--SET @startTime = DATEADD(minute,-24,DATEADD(HOUR, -8, GETDATE()))
--SET @endTime = DATEADD(HOUR, -8, GETDATE())

SET @startTime = DATEADD(minute,-64,DATEADD(HOUR, -8, GETDATE()))
SET @endTime = DATEADD(minute,-24,DATEADD(HOUR, -8, GETDATE()))

select 
N'CPU最大值: '+ CAST(CAST(MAX([value]/60) as int) as nvarchar) + '%' 
,N'分鐘CPU平均值: '+CAST(CAST(AVG([value]/60) as int) as nvarchar)+ '%' 
--as [PERCENT_PROCESSOR_TIME AVG]
--,CAST(MAX([value]) as int) as [PERCENT_PROCESSOR_TIME MAX]
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 71 -- PROCESS	PERCENT_PROCESSOR_TIME
and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(@endTime)



select N'Connection最大值: '+CAST(CAST(MAX([value]) as int) as nvarchar)
,N'分鐘Connection平均值: '+CAST(CAST(avg([value]) as int) as nvarchar) 
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(@endTime)

-- Connection最大值: 2474	分鐘Connection平均值: 2136
--Connection最大值: 2359	分鐘Connection平均值: 1947


select N'Batch requests/sec最大值: '+CAST(CAST(MAX([value]) as int) as nvarchar)
,N'分鐘Batch requests/sec平均值: '+CAST(CAST(avg([value]) as int) as nvarchar) 
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= SQLSentry.dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < SQLSentry.dbo.fnConvertDateTimeToTimestamp(@endTime)

-- Batch requests/sec最大值: 2474	分鐘Batch requests/sec平均值: 2136
--Batch requests/sec最大值: 2359	分鐘Batch requests/sec平均值: 1947













USE [SQLSentry]
GO
DECLARE @startTime datetime = '2016-11-07 20:20:00'
DECLARE @endTime datetime = '2016-11-11 20:40:00'

SET @startTime = DATEADD(HOUR, -8, @startTime)
SET @endTime = DATEADD(HOUR, -8, @endTime)


select 
'2016-11-07' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
UNION ALL
select 
'2016-11-08' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @endTime))
UNION ALL
select 
'2016-11-09' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @endTime))
UNION ALL
select 
'2016-11-10' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @endTime))
UNION ALL
select 
'2016-11-11' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +4, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +4, @endTime))




select 
'2016-11-07' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
UNION ALL
select 
'2016-11-08' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @endTime))
UNION ALL
select 
'2016-11-09' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @endTime))
UNION ALL
select 
'2016-11-10' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @endTime))
UNION ALL
select 
'2016-11-11' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +4, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +4, @endTime))






SET @startTime = '2016-11-01 20:20:00'
SET @endTime = '2016-11-04 20:40:00'

SET @startTime = DATEADD(HOUR, -8, @startTime)
SET @endTime = DATEADD(HOUR, -8, @endTime)


select 
'2016-11-01' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
UNION ALL
select 
'2016-11-02' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @endTime))
UNION ALL
select 
'2016-11-03' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @endTime))
UNION ALL
select 
'2016-11-04' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [USER_CONNECTIONS AVG]
,CAST(MAX([value]) as int) as [USER_CONNECTIONS MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @endTime))




select 
'2016-11-01' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
UNION ALL
select 
'2016-11-02' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +1, @endTime))
UNION ALL
select 
'2016-11-03' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +2, @endTime))
UNION ALL
select 
'2016-11-04' as [Time 20:20-20:40]
,CAST(avg([value]) as int) as [BATCH_REQUESTS_PER_SEC AVG]
,CAST(MAX([value]) as int) as [BATCH_REQUESTS_PER_SEC MAX]
from PerformanceMonitor.SQLSentry.PerformanceAnalysisData201611
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @startTime))
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(DATEADD(DAY, +3, @endTime))



USE PerformanceMonitor
GO
SELECT  
  pacc.CategoryResourceName AS Category,
  pac.CounterResourceName AS Counter,
  pac.ID
FROM SQLSentry.PerformanceAnalysisCounter AS pac
INNER JOIN SQLSentry.PerformanceAnalysisCounterCategory AS pacc
  ON pac.PerformanceAnalysisCounterCategoryID = pacc.ID
Group by pacc.CategoryResourceName, pac.CounterResourceName, pac.ID

--Category	Counter	ID
--SQLSERVER:GENERAL_STATISTICS	LOGINS_PER_SEC	183
--SQLSERVER:GENERAL_STATISTICS	LOGOUTS_PER_SEC	184
--SQLSERVER:GENERAL_STATISTICS	PROCESSES_BLOCKED	1665
--SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS	1



USE [SQLSentry]
GO
DECLARE @startTime datetime = '2016-11-15 17:00:00'
DECLARE @endTime datetime = '2016-11-15 17:15:00'

SET @startTime = DATEADD(HOUR, -8, @startTime)
SET @endTime = DATEADD(HOUR, -8, @endTime)


select 
DATEADD(HOUR,+8,dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time],
--dbo.fnConvertTimestampToDateTime([Timestamp]) as [Time],
cast([value]/60 as int) as [CPU Avg Usage%]
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 71 -- PROCESS	PERCENT_PROCESSOR_TIME
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
order by [Timestamp]


select 
DATEADD(HOUR,+8,dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time],
CAST([value] as int) as [USER_CONNECTIONS]
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 185 -- SQLSERVER:GENERAL_STATISTICS	USER_CONNECTIONS
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
order by [Time]



USE [SQLSentry]
GO
DECLARE @startTime datetime = '2016-11-16 10:30:00'
DECLARE @endTime datetime = '2016-11-16 11:30:00'

SET @startTime = DATEADD(HOUR, -8, @startTime)
SET @endTime = DATEADD(HOUR, -8, @endTime)


select 
DATEADD(HOUR,+8,dbo.fnConvertTimestampToDateTime([Timestamp])) as [Time],
CAST([value] as int) as [BATCH_REQUESTS_PER_SEC]
from SQLSentry.dbo.PerformanceAnalysisData
where 
DeviceID = 1
and PerformanceAnalysisCounterID = 212 -- SQLSERVER:SQL_STATISTICS	BATCH_REQUESTS_PER_SEC
and [Timestamp] >= dbo.fnConvertDateTimeToTimestamp(@startTime)
and [Timestamp] < dbo.fnConvertDateTimeToTimestamp(@endTime)
order by [Time]




USE PerformanceMonitor
GO
SELECT  
  pacc.CategoryResourceName AS Category,
  pac.CounterResourceName AS Counter,
  pac.ID
  ,*
  --pasi.Name AS SampleInterval,
  --pasi.IntervalInTicks/10000000 AS IntervalInSeconds
FROM SQLSentry.PerformanceAnalysisCounter AS pac
INNER JOIN SQLSentry.PerformanceAnalysisCounterCategory AS pacc
  ON pac.PerformanceAnalysisCounterCategoryID = pacc.ID
--LEFT OUTER JOIN SQLSentry.PerformanceAnalysisSampleInterval AS pasi
--  ON pac.PerformanceAnalysisSampleIntervalID = pasi.ID
WHERE
  pac.PerformanceAnalysisSampleIntervalID > 0 
  AND pacc.ID <> 29 --SQLPERF:WAITSTATS Category ID
  --AND pacc.CategoryResourceName NOT LIKE N'%SSAS%'
ORDER BY pacc.CategoryResourceName, pac.CounterResourceName;

