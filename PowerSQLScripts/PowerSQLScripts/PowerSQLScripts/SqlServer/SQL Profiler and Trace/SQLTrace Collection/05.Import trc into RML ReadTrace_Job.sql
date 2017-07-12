-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/12
-- Description:	SQLTrace Collection Step 5

-- =============================================

USE [msdb]
GO

/****** Object:  Job [Auto Generate ReadTrace Report Data(SQLServer01)]    Script Date: 07/12/2017 12:00:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 07/12/2017 12:00:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Auto Generate ReadTrace Report Data(SQLServer01)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'/* 2017-02-07 */
目前二、三、四、日與不定期的SQLServer01上收Trace(pick time for 10 minutes), 設計自動丟到readtrace工具產成db file, 由DAL成員自行去取report.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'dbasa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Trace  File From TEPCDB08]    Script Date: 07/12/2017 12:00:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Trace  File From TEPCDB08', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec master.dbo.xp_cmdshell ''D:\DBA\CopyBackupFilesFromSQLServer01.cmd'';
go', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ReadTrace for ALL trace file]    Script Date: 07/12/2017 12:00:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ReadTrace for ALL trace file', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @FindDate varchar(10);
declare @FindFolder varchar(13);
declare @TraceFolderName varchar(19);
declare @FullTraceFolderName varchar(100);
declare @ReadTraceDatabaseName varchar(50);
declare @FirstTraceFileName varchar(100);
declare @ReadTraceCommand varchar(500);

declare @vtabFolderList table
(
	subdirectory varchar(100),
	depth tinyint,
	[file] tinyint
);
declare @vtabFileList table
(
	subdirectory varchar(100),
	depth tinyint,
	[file] tinyint
);
set @FindDate = left(convert(varchar(20), dateadd(day, -1, getdate()), 120), 10)
set @FindFolder = @FindDate + ''_20%''


insert into @vtabFolderList (subdirectory, depth, [file])
exec xp_dirtree ''D:\SQLTraceFiles'' , 1, 1

select top 1 @TraceFolderName = subdirectory from @vtabFolderList
where
		[file] = 0 
	and left(subdirectory, 13) like @FindFolder

set @FullTraceFolderName = ''D:\SQLTraceFiles\'' +  @TraceFolderName
set @ReadTraceDatabaseName = ''ReadTraceDB'' + replace(replace(@TraceFolderName, ''-'', ''''), ''_'', '''')


insert into @vtabFileList (subdirectory, depth, [file])
exec xp_dirtree @FullTraceFolderName, 1, 1

select top 1 @FirstTraceFileName = subdirectory from @vtabFileList
where
		depth = 1
	and [file] = 1
order by subdirectory

set @ReadTraceCommand = 
''call "C:\Program Files\Microsoft Corporation\RMLUtils\ReadTrace.exe" -S"(local)" -E -d"'' + @ReadTraceDatabaseName + ''" -I"'' 
+ @FullTraceFolderName + ''\'' + @FirstTraceFileName + ''" -o"'' + @FullTraceFolderName + ''\output" -T18''

exec xp_cmdshell @ReadTraceCommand', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ReadTrace for PickTime trace files]    Script Date: 07/12/2017 12:00:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ReadTrace for PickTime trace files', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
declare @FindDate varchar(10);
declare @FindFolder varchar(13);
declare @TraceFolderName varchar(19);
declare @FullTraceFolderName varchar(100);
declare @ReadTraceDatabaseName varchar(50);
declare @FirstTraceFileName varchar(100);
declare @ReadTraceCommand varchar(500);
declare @maxid int;
declare @minid int;
declare @filecount int;
declare @cmdscript varchar(1000);

declare @vtabFolderList table
(
	subdirectory varchar(100),
	depth tinyint,
	[file] tinyint
);
declare @vtabDirList table ([output] varchar(1000));
declare @vtabDirFileList table
(
	capturetime varchar(5), 
	[filename] varchar(100), 
	id bigint
);
set @FindDate = left(convert(varchar(20), dateadd(day, -1, getdate()), 120), 10);
set @FindFolder = @FindDate + ''_20%'';


insert into @vtabFolderList (subdirectory, depth, [file])
exec xp_dirtree ''D:\SQLTraceFiles'' , 1, 1;

select top 1 @TraceFolderName = subdirectory from @vtabFolderList
where
		[file] = 0 
	and left(subdirectory, 13) like @FindFolder;

set @FullTraceFolderName = ''D:\SQLTraceFiles\'' +  @TraceFolderName;
set @ReadTraceDatabaseName = ''ReadTraceDB'' + replace(replace(@TraceFolderName, ''-'', ''''), ''_'', '''') + ''_peak'';
set @cmdscript = ''dir '' + @FullTraceFolderName

insert @vtabDirList ([output])
exec xp_cmdshell @cmdscript


insert into @vtabDirFileList (capturetime, [filename], id)
select 
	substring([output], 13, 5) capturetime,
	reverse(left(reverse([output]), charindex('' '', reverse([output])) -1)) as [filename],
	convert(bigint, left(reverse(left(reverse([output]), charindex(''_'', reverse([output])) -1)), charindex(''.'', reverse(left(reverse([output]), charindex(''_'', reverse([output])) -1)))-1)) as id
from @vtabDirList
where 
	[output] like ''%.trc%''
order by id;


select @minid = max(id) from @vtabDirFileList
where capturetime = ''08:29'';
select @maxid = min(id) from @vtabDirFileList
where capturetime = ''08:34'';
select @filecount = count(*) from @vtabDirFileList
where id between @minid and @maxid;
select @FirstTraceFileName = [filename] from @vtabDirFileList
where id = @minid;

set @ReadTraceCommand = 
''call "C:\Program Files\Microsoft Corporation\RMLUtils\ReadTrace.exe" -S"(local)" -E -d"'' + @ReadTraceDatabaseName + ''" -I"'' 
+ @FullTraceFolderName + ''\'' + @FirstTraceFileName + ''" -r'' + convert(varchar, @filecount) + '' -o"'' + @FullTraceFolderName + ''\output_peak" -T18'';

exec xp_cmdshell @ReadTraceCommand;

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Start at 1:00 every day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170207, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'49ddd319-1325-43ac-92c5-b88b745a6f85'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


