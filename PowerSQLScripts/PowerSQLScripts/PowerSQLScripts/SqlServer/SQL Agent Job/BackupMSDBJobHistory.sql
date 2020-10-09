USE [MSDBLOG]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Brad Chen
-- Create date:    2020/10/09 
-- Description:    Backup Job History and keep in retention day
-- Modified By    Modification Date    Modification Description

-- EXEC dbo.uspBackupJobHistory @retention = -60
-- Keep job history in 60 day

-- =============================================
ALTER proc [dbo].[uspBackupJobHistory]
 @retention int
AS
	set nocount on;

	DECLARE @RetYYYYMMDD int, @RetInstanceId int, @MaxInstanceId int;
	SET @RetYYYYMMDD = CAST(convert(varchar(8), DATEADD(DAY, @retention,GETDATE()), 112) as int);

	
	BEGIN TRAN
		-- Step 1: Delete row below @RetYYYYMMDD
		SELECT @RetInstanceId = MAX([instance_id]) 
			FROM [MSDBLOG].[dbo].[sysjobhistory] 
			WHERE [run_date] = @RetYYYYMMDD;
		DELETE [MSDBLOG].[dbo].[sysjobhistory] 
			WHERE [instance_id] <= @RetInstanceId;

		-- Step 2: Query msdb.sys.sysjobhistory insert into [MSDBLOG].[dbo].[sysjobhistory]
		SELECT @MaxInstanceId = MAX([instance_id]) 
			FROM [MSDBLOG].[dbo].[sysjobhistory];

		INSERT INTO [MSDBLOG].[dbo].[sysjobhistory]
			SELECT [instance_id]
				,[job_id]
				,[step_id]
				,[step_name]
				,[sql_message_id]
				,[sql_severity]
				,[message]
				,[run_status]
				,[run_date]
				,[run_time]
				,[run_duration]
				,[operator_id_emailed]
				,[operator_id_netsent]
				,[operator_id_paged]
				,[retries_attempted]
				,[server]
			FROM [msdb].[dbo].[sysjobhistory] where [run_date] > @MaxInstanceId;
	COMMIT;
