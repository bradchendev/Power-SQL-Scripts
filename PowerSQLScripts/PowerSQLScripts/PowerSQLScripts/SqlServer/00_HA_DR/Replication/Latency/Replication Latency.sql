-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/9/27
-- Description:	Replication Latency

-- =============================================



-- create a [DBA_ReplicationLatencyLogCollection] job in publisher for latency collection(trigger Tracer Token)
USE [AdventureWorks2008R2]
GO
EXEC sys.sp_posttracertoken @publication = 'Pub01'
Go
EXEC sys.sp_posttracertoken @publication = 'Pub02'
Go

-- Create a view for Replication Latency( Tracer Token record) Monitoring.
USE [DBA]
CREATE view [dbo].[vwReplicationLatency]
AS
SELECT 
--tok.tracer_id,
--hist.agent_id,
tok.publication_id,
pub.publication,
tok.publisher_commit,
DATEDIFF(millisecond, tok.publisher_commit,tok.distributor_commit) as [Pub to Dist (ms)],
DATEDIFF(millisecond, tok.distributor_commit, hist.subscriber_commit) as [Dist to Sub (ms)],
DATEDIFF(millisecond, tok.publisher_commit, hist.subscriber_commit) as [Total deplay (ms)]
--tok.distributor_commit,
--ist.subscriber_commit
FROM distribution.dbo.MStracer_tokens tok
INNER JOIN distribution.dbo.MSpublications pub
ON tok.publication_id = pub.publication_id
LEFT JOIN distribution.dbo.MStracer_history hist
ON tok.tracer_id = hist.parent_tracer_id
GO


-- Create two table for latency history ( Tracer Token history)
USE [DBA]
CREATE TABLE [dbo].[MStracer_history_history](
	[parent_tracer_id] [int] NOT NULL,
	[agent_id] [int] NOT NULL,
	[subscriber_commit] [datetime] NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[MStracer_tokens_history](
	[tracer_id] [int] NOT NULL,
	[publication_id] [int] NOT NULL,
	[publisher_commit] [datetime] NOT NULL,
	[distributor_commit] [datetime] NULL,
 CONSTRAINT [PK_MStracer_tokens_history] PRIMARY KEY CLUSTERED 
(
	[tracer_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


-- Create a Proc for keep Tracer Token history
-- CREATE BY: Brad Chen
-- CREATE DATE: 2017-07-03

CREATE PROC [dbo].[uspKeepTracerTokenHistory]
AS
	PRINT '1.Start to move distribution.dbo.MStracer_tokens to DBA.dbo.MStracer_tokens_history'
	-- distribution.dbo.MStracer_tokens
	DECLARE @MAX_TRACER_ID_TokenTable int
	DECLARE @publisher_commit datetime

	SELECT @MAX_TRACER_ID_TokenTable = MAX(tracer_id) FROM dbo.MStracer_tokens_history
	--SELECT @publisher_commit = publisher_commit FROM dbo.MStracer_tokens_history
	--where tracer_id = @MAX_TRACER_ID_TokenTable

	--select @MAX_TRACER_ID_TokenTable
	--select @publisher_commit
	
	IF @MAX_TRACER_ID_TokenTable is NULL
	BEGIN
		INSERT INTO dbo.MStracer_tokens_history
		SELECT * FROM distribution.dbo.MStracer_tokens;
	END;
	ELSE
	BEGIN
		INSERT INTO dbo.MStracer_tokens_history
		SELECT * FROM distribution.dbo.MStracer_tokens
		WHERE tracer_id > @MAX_TRACER_ID_TokenTable;
	END;

	PRINT '2.Start to move distribution.dbo.MStracer_history to DBA.dbo.MStracer_history_history'
	-- distribution.dbo.MStracer_history
	DECLARE @MAX_TRACER_ID_HistoryTable int
	DECLARE @distribution_commit datetime

	SELECT @MAX_TRACER_ID_HistoryTable = MAX(parent_tracer_id) FROM dbo.MStracer_history_history
	--SELECT @distribution_commit = distribution_commit FROM dbo.MStracer_history_history
	--where parent_tracer_id = @MAX_TRACER_ID_HistoryTable

	--select @@MAX_TRACER_ID_HistoryTable
	--select @@distribution_commit

	IF @MAX_TRACER_ID_HistoryTable is NULL
	BEGIN
		INSERT INTO dbo.MStracer_history_history
		SELECT * FROM distribution.dbo.MStracer_history
	END;
	ELSE
	BEGIN
		INSERT INTO dbo.MStracer_history_history
		SELECT * FROM distribution.dbo.MStracer_history
		WHERE parent_tracer_id > @MAX_TRACER_ID_HistoryTable;
	END;
	
	-- delete	
	PRINT '3.Delete MStracer_tokens_history where publisher_commit > 30 day'
	DELETE dbo.MStracer_tokens_history
	WHERE publisher_commit < CAST(DATEADD(DAY, -30, GETDATE()) AS DATE);

	PRINT '4.Delete MStracer_history_history where subscriber_commit > 30 day'	
	DELETE dbo.MStracer_history_history
	WHERE subscriber_commit < CAST(DATEADD(DAY, -30, GETDATE()) AS DATE);

GO



-- create a Job [DBA_ReplicationKeepTracerTokenHistory] run  [dbo].[uspKeepTracerTokenHistory] every day


