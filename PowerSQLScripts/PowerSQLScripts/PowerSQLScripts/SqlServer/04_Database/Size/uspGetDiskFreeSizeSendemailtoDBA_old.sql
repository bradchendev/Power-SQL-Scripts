-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2016/12/28
-- Description:	

-- =============================================

USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]    Script Date: 12/28/2016 10:07:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Brad Chen
-- Create date:    2016/11/18 
-- Description:    檢查磁碟機可用空間
-- Modified By    Modification Date    Modification Description
-- EXEC dbo.uspGetDiskFreeSizeSendemailtoDBA
-- =============================================
CREATE procedure [dbo].[uspGetDiskFreeSizeSendemailtoDBA]
AS
DECLARE @disk table
(
RowID int identity(1,1)
,[drive] nvarchar(1)
,[FreeSize(MB)] int
);

DECLARE @RowID INT = 1, @MaxRowID INT;
DECLARE @drive nvarchar(1) , @FreeSize int
DECLARE @htmlbody nvarchar(2000)
SET @htmlbody = ''
DECLARE @htmlTable nvarchar(2000)
SET @htmlTable = ''

SET @htmlTable = N'<tr><td>drive</td><td>FreeSize(MB)</td><td>說明</td></tr>'

INSERT INTO @disk([drive],[FreeSize(MB)])
EXEC master..xp_fixeddrives



SELECT @MaxRowID = MAX(RowID) FROM @disk
WHILE @RowID <= @MaxRowID
BEGIN
	select 
		@drive = [drive], 
		@FreeSize = [FreeSize(MB)] 
	from @disk where RowID = @RowID
   
	If  @FreeSize < 1024 and @drive not in ('Q','K')
	BEGIN  
		-- 小於1G
	  SET  @htmlTable = @htmlTable + N'<tr style="font-weight: bold; color: red;"><td>' + @drive + N'</td><td align="right">'+ CAST(@FreeSize as nvarchar) + N'</td><td>可用空間小於1GB</td></tr>'
	END
	ELSE
	BEGIN  
	SET  @htmlTable = @htmlTable + N'<tr ><td>' + @drive + N'</td><td align="right"> '+ REPLACE(CONVERT(NVARCHAR,CONVERT(MONEY,@FreeSize),1), '.00','') + N'</td><td>&nbsp;</td></tr>'
	END

    SET @RowID = @RowID + 1;
END

SET @htmlbody =  N'<html>'
SET @htmlbody =  @htmlbody + N'檢查主機: ' + @@SERVERNAME + '<p>'
SET @htmlbody =  @htmlbody + N'檢查時間: ' + CONVERT(nvarchar(23), GETDATE(), 121) + '<p>'
SET @htmlbody =  @htmlbody + N'如果可用空間小於1G並且磁碟代號不是Q或K則會出現紅色字體<p>'
SET @htmlbody =  @htmlbody + N'<table border="1">' + @htmlTable +  N'</table></html>'

--SELECT @htmlbody

    EXEC msdb.dbo.sp_send_dbmail
      @profile_name = NULL,
      @recipients = 'bradchen@contoso.com',
      @subject = 'Disk Free size',
      @body_format = 'HTML',
      @body = @htmlbody

GO


