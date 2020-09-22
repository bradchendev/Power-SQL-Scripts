USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]    Script Date: 2020/9/22 下午 03:23:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:        Brad Chen
-- Create date:    2020/9/22
-- Description:    檢查磁碟機可用空間與DB Information
-- Modified By    Modification Date    Modification Description
-- 2020-09-22 add DB Information
-- EXEC dbo.uspGetDiskFreeSizeSendemailtoDBA @ThresholdFreeSizeMB=1024,@recipientsList = 'xxx@test.com'
-- EXEC dbo.uspGetDiskFreeSizeSendemailtoDBA @ThresholdFreeSizeMB=1024,@recipientsList = 'xxx@test.com;xxx2@test.com'
-- =============================================
ALTER procedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]
@ThresholdFreeSizeMB int, 
@recipientsList varchar(500)
AS
	SET NOCOUNT ON;
	DECLARE @emailTitle nvarchar(100)
	DECLARE @disk table
	(
	[RowID] int identity(1,1),
	[Server] nvarchar(30),
	[drive] nvarchar(1),
	[FreeSize(MB)] int
	);


	DECLARE @dbInfo table
	(
		RowID int identity(1,1),
		[Server] [sysname] NULL,
		[name] [sysname] NULL,
		[state_desc] [nvarchar](60) NULL,
		[is_read_only] [bit] NULL,
		[user_access_desc] [nvarchar](60) NULL,
		[recovery_model_desc] [nvarchar](60) NULL,
		[log_reuse_wait_desc] [nvarchar](60) NULL,
		[compatibility_level] [tinyint] NOT NULL,
		[collation_name] [sysname] NULL
	);


	-- D18ETLA01
	BEGIN TRAN
		INSERT INTO @disk([drive],[FreeSize(MB)])
		EXEC master..xp_fixeddrives;

		update @disk
		set [Server] = @@SERVERNAME
		where [server] is null;
	COMMIT TRAN;
	
	INSERT INTO @dbInfo
	(
	[Server],
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name])
	SELECT 
	N'D18ETLA01',
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name] 
	from [master].[sys].[databases];

	-- D18LOCALDBA01
	BEGIN TRAN
	INSERT INTO @disk([drive],[FreeSize(MB)])
	EXEC [D18LOCALDBA01].[master]..[xp_fixeddrives]

	update @disk
	set [Server] = N'D18LOCALDBA01'
	where [server] is null;
	COMMIT TRAN;

	INSERT INTO @dbInfo
	(
	[Server],
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name])
	SELECT 
	N'D18LOCALDBA01',
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name] 
	from [D18LOCALDBA01].[master].[sys].[databases];

	-- D18DWDBA01
	BEGIN TRAN
		INSERT INTO @disk([drive],[FreeSize(MB)])
		EXEC [D18DWDBA01].[master]..[xp_fixeddrives]

		update @disk
		set [Server] = N'D18DWDBA01'
		where [server] is null;
	COMMIT TRAN;

	INSERT INTO @dbInfo
	(
	[Server],
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name])
	SELECT 
	N'D18DWDBA01',
	[name],
	[state_desc],
	[is_read_only],
	[user_access_desc],
	[recovery_model_desc],
	[log_reuse_wait_desc],
	[compatibility_level],
	[collation_name] 
	from [D18DWDBA01].[master].[sys].[databases];


	DECLARE @RowID INT = 1, @MaxRowID INT;
	DECLARE @Server nvarchar(30), @drive nvarchar(1) , @FreeSize int
	DECLARE @db sysname, @state nvarchar(30), @isReadOnly int, @userAccess nvarchar(30), 
	@recoveryModel nvarchar(20),@logReuseWait nvarchar(30),@compaLevel int, @Collation nvarchar(30)

	DECLARE @htmlbody nvarchar(max)
	SET @htmlbody = ''


	-- HTML TABLE 1 for drive size
	DECLARE @htmlTable nvarchar(2000)
	SET @htmlTable = ''
	SET @htmlTable = N'<tr><td>Server</td><td>drive</td><td>FreeSize(MB)</td><td>說明</td></tr>'

	DECLARE @AlertDiskCnt int = 0;

	SELECT @MaxRowID = MAX(RowID) FROM @disk
	WHILE @RowID <= @MaxRowID
	BEGIN
		select 
			@Server = [Server],
			@drive = [drive], 
			@FreeSize = [FreeSize(MB)] 
		from @disk where RowID = @RowID
   
		--If  @FreeSize < 1024 and @drive not in ('Q','K')
		If  @FreeSize < @ThresholdFreeSizeMB 
		BEGIN  
			-- 小於1G
			SET @AlertDiskCnt = @AlertDiskCnt + 1;
			SET @htmlTable = @htmlTable + N'<tr style="font-weight: bold; color: red;"><td>' + @Server + N'</td><td>' + @drive + N'</td><td align="right">'+ CAST(@FreeSize as nvarchar) + N'</td><td>可用空間小於 ' + CAST(@ThresholdFreeSizeMB as nvarchar) + ' MB </td></tr>'
		END
		ELSE
		BEGIN  
			SET @htmlTable = @htmlTable + N'<tr ><td>' + @Server + N'</td><td>' + @drive + N'</td><td align="right"> '+ REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY,@FreeSize),1), '.00','') + N'</td><td>&nbsp;</td></tr>'
		END

		SET @RowID = @RowID + 1;
	END

	-- HTML TABLE 2 for DB information
	DECLARE @htmlTable2 nvarchar(max)
	SET @htmlTable2 = ''
	SET @htmlTable2 = N'<tr><td>Server</td>'
							+ N'<td>DB</td>'
							+ N'<td>state_desc</td>'
							+ N'<td>is_read_only</td>'
							+ N'<td>user_access_desc</td>'
							+ N'<td>recovery_model_desc</td>'
							+ N'<td>log_reuse_wait_desc</td>'
							+ N'<td>compatibility_level</td>'
							+ N'<td>collation_name</td>'
							+ N'</tr>'
	SET @RowID = 1
	SELECT @MaxRowID = MAX(RowID) FROM @dbInfo
	WHILE @RowID <= @MaxRowID
	BEGIN
		select 
			@Server = [Server],
			@db = [name], 
			@state = [state_desc], 
			@isReadOnly = [is_read_only], 
			@userAccess = [user_access_desc], 
			@recoveryModel = [recovery_model_desc], 
			@logReuseWait = [log_reuse_wait_desc], 
			@compaLevel = [compatibility_level], 
			@Collation = [collation_name] 
		from @dbInfo where RowID = @RowID
   

		SET @htmlTable2 = @htmlTable2 + N'<tr>' 
					+ N'<td>' + @Server + N'</td>' 
					+ N'<td>' + @db + N'</td>' 
					+ N'<td>' + @state + N'</td>' 
					+ N'<td>' + CAST(@isReadOnly as nvarchar(2)) + N'</td>' 
					+ N'<td>' + @userAccess + N'</td>' 
					+ N'<td>' + @recoveryModel + N'</td>' 
					+ N'<td>' + @logReuseWait + N'</td>' 
					+ N'<td>' + CAST(@compaLevel as nvarchar(5)) + N'</td>' 
					+ N'<td>' + @Collation + N'</td>' 
					+ N'</tr>'

		SET @RowID = @RowID + 1;
	END


	-- HTML BODY
	SET @htmlbody =  N'<html>'
	SET @htmlbody =  @htmlbody + N'檢查主機: ' + @@SERVERNAME + '<p>'
	SET @htmlbody =  @htmlbody + N'檢查時間: ' + CONVERT(nvarchar(23), GETDATE(), 121) + '<p>'
	--SET @htmlbody =  @htmlbody + N'如果可用空間小於1G並且磁碟代號不是Q或K則會出現紅色字體<p>'
	SET @htmlbody =  @htmlbody + N'檢查值: ' + CAST(@ThresholdFreeSizeMB as nvarchar) + ' MB (低於此值下表會呈現紅色字體)<p>'
	SET @htmlbody =  @htmlbody + N'<table border="1">' + @htmlTable +  N'</table><br><br><table border="1">' + @htmlTable2 +  N'</table></html>'

	--SET @emailTitle = 'Disk Free size - [' + @@SERVERNAME + ']';
	SET @emailTitle = 'D18 SQL Server Disk Free size';

	IF @AlertDiskCnt > 0
	BEGIN
		SET @emailTitle = @emailTitle + N' 有 ' + CAST(@AlertDiskCnt as nvarchar) + N' 個磁碟低於檢查值';
	END;

	--SELECT @htmlbody

    EXEC msdb.dbo.sp_send_dbmail
      @profile_name = NULL,
      @recipients = @recipientsList,
      @subject = @emailTitle,
      @body_format = 'HTML',
      @body = @htmlbody

