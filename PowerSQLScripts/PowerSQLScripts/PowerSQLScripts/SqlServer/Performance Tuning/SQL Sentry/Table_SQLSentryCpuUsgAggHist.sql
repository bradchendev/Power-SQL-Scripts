USE [DBA]
GO

/****** Object:  Table [dbo].[SQLSentryCpuUsgAggHist]    Script Date: 04/30/2018 14:21:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SQLSentryCpuUsgAggHist](
	[sn] [int] IDENTITY(1,1) NOT NULL,
	[SentryLogDate] [date] NULL,
	[WeekDay] [nchar](1) NULL,
	[DbServer] [varchar](50) NULL,
	[PerfCountId] [int] NULL,
	[Min] [int] NULL,
	[Max] [int] NULL,
	[Avg] [int] NULL,
 CONSTRAINT [PK_SQLSentryCpuUsgAggHist] PRIMARY KEY CLUSTERED 
(
	[sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


