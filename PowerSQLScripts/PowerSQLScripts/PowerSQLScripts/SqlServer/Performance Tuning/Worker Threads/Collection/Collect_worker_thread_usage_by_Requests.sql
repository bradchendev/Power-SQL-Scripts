USE [DBA]
GO

/****** Object:  Table [Perf].[Collect_worker_thread_usage_by_Requests]    Script Date: 12/28/2016 10:18:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Perf].[Collect_worker_thread_usage_by_Requests](
	[sn] [int] IDENTITY(1,1) NOT NULL,
	[CollectTime] [datetime] NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[session_id] [smallint] NULL,
	[COUNT] [int] NULL,
 CONSTRAINT [PK_Collect_worker_thread_usage_by_Requests] PRIMARY KEY CLUSTERED 
(
	[sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

