USE [DBA]
GO

/****** Object:  Table [Perf].[Collect_sessions_status]    Script Date: 12/28/2016 10:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [Perf].[Collect_sessions_status](
	[sn] [int] IDENTITY(1,1) NOT NULL,
	[CollectTime] [datetime] NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[spid] [smallint] NOT NULL,
	[Parent Query] [nvarchar](max) NULL,
	[hostname] [nchar](128) NOT NULL,
	[loginame] [nchar](128) NOT NULL,
	[program_name] [nchar](128) NOT NULL,
	[status] [nchar](30) NOT NULL,
	[waittype] [binary](2) NOT NULL,
	[waitresource] [nchar](256) NOT NULL,
	[kpid] [smallint] NOT NULL,
	[blocked] [smallint] NOT NULL,
 CONSTRAINT [PK_Collect_sessions_status] PRIMARY KEY CLUSTERED 
(
	[sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

