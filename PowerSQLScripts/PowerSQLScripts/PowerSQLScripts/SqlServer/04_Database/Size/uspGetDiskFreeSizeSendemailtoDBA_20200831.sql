USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]    Script Date: 2020/9/14 上午 11:28:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Brad Chen
-- Create date:    2020/9/14 
-- Description:    檢查磁碟機可用空間
-- Modified By    Modification Date    Modification Description
-- EXEC dbo.uspGetDiskFreeSizeSendemailtoDBA @ThresholdFreeSizeMB=1024,@recipientsList = 'bradchen@systex.com'
-- EXEC dbo.uspGetDiskFreeSizeSendemailtoDBA @ThresholdFreeSizeMB=1024,@recipientsList = 'bradchen@systex.com;ethancheng@systex.com'
-- =============================================
ALTER procedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]
@ThresholdFreeSizeMB int, 
@recipientsList varchar(500)
AS
SET NOCOUNT ON;
DECLARE @emailTitle nvarchar(100)
DECLARE @disk table
(
RowID int identity(1,1)
,[Server] nvarchar(30)
,[drive] nvarchar(1)
,[FreeSize(MB)] int
);

DECLARE @RowID INT = 1, @MaxRowID INT;
DECLARE @Server nvarchar(30), @drive nvarchar(1) , @FreeSize int

DECLARE @htmlbody nvarchar(2000)
SET @htmlbody = ''
DECLARE @htmlTable nvarchar(2000)
SET @htmlTable = ''

SET @htmlTable = N'<tr><td>Server</td><td>drive</td><td>FreeSize(MB)</td><td>說明</td></tr>'

-- D18ETLA01
INSERT INTO @disk([drive],[FreeSize(MB)])
EXEC master..xp_fixeddrives

update @disk
set [Server] = @@SERVERNAME
where [server] is null;

-- D18LOCALDBA01
INSERT INTO @disk([drive],[FreeSize(MB)])
EXEC [D18LOCALDBA01].[master]..[xp_fixeddrives]

update @disk
set [Server] = N'D18LOCALDBA01'
where [server] is null;

-- D18DWDBA01
INSERT INTO @disk([drive],[FreeSize(MB)])
EXEC [D18DWDBA01].[master]..[xp_fixeddrives]

update @disk
set [Server] = N'D18DWDBA01'
where [server] is null;


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

SET @htmlbody =  N'<html>'
SET @htmlbody =  @htmlbody + N'檢查主機: ' + @@SERVERNAME + '<p>'
SET @htmlbody =  @htmlbody + N'檢查時間: ' + CONVERT(nvarchar(23), GETDATE(), 121) + '<p>'
--SET @htmlbody =  @htmlbody + N'如果可用空間小於1G並且磁碟代號不是Q或K則會出現紅色字體<p>'
SET @htmlbody =  @htmlbody + N'檢查值: ' + CAST(@ThresholdFreeSizeMB as nvarchar) + ' MB (低於此值下表會呈現紅色字體)<p>'
SET @htmlbody =  @htmlbody + N'<table border="1">' + @htmlTable +  N'</table></html>'


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

GO


