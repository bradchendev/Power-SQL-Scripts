USE [DBA]
GO

/****** Object:  View [Perf].[vwListSessionWithWorkerThreads]    Script Date: 12/28/2016 10:17:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Perf].[vwListSessionWithWorkerThreads]
AS
-- create by Brad

SELECT 
a.sn,
a.CollectTime,
a.ServerName,
a.[COUNT] as [Worker threads],
b.[Parent Query]
FROM Perf.Collect_worker_thread_usage_by_Requests as a
inner join Perf.Collect_sessions_status as b
ON a.CollectTime = b.CollectTime 
and a.ServerName = b.ServerName
and a.session_id = b.spid

GO

