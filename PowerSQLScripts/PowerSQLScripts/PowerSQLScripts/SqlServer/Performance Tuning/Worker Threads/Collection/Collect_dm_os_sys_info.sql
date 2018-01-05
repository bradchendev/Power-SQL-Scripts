USE [DBA]
GO

/****** Object:  Table [Perf].[Collect_dm_os_sys_info]    Script Date: 12/28/2016 10:18:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Perf].[Collect_dm_os_sys_info](
	[sn] [int] IDENTITY(1,1) NOT NULL,
	[CollectTime] [datetime] NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[sqlserver_start_time] [datetime] NOT NULL,
	[max_workers_count] [int] NOT NULL,
	[stack_size_in_bytes] [int] NOT NULL,
	[cpu_count] [int] NOT NULL,
	[scheduler_count] [int] NOT NULL,
	[physical_memory_in_bytes] [bigint] NOT NULL,
	[virtual_memory_in_bytes] [bigint] NOT NULL,
	[bpool_committed] [int] NOT NULL,
	[bpool_commit_target] [int] NOT NULL,
 CONSTRAINT [PK_Collect_dm_os_sys_info] PRIMARY KEY CLUSTERED 
(
	[sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO

