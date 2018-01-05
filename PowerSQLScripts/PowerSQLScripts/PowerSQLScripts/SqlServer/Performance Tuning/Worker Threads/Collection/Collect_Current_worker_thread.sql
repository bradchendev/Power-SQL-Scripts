USE [DBA]
GO

/****** Object:  Table [Perf].[Collect_Current_worker_thread]    Script Date: 12/28/2016 10:18:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Perf].[Collect_Current_worker_thread](
	[sn] [int] IDENTITY(1,1) NOT NULL,
	[CollectTime] [datetime] NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[Current worker thread] [int] NULL,
 CONSTRAINT [PK_Collect_Current_worker_thread] PRIMARY KEY CLUSTERED 
(
	[sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

