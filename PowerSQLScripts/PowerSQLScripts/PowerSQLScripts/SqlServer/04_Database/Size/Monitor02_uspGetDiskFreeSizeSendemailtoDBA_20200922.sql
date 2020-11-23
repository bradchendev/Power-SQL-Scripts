USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspQueryDbFileSizeSendtoDBA]    Script Date: 2020/11/23 上午 10:56:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Brad Chen
-- Create date:    2020/8/31 
-- Description:    查詢Db File size發信給DBA
-- Modified By    Modification Date    Modification Description
-- EXEC dbo.uspQueryDbFileSizeSendtoDBA @chkTime = '2020-10-21 23:00:00', @ThresholdFreeSizeMB = 1024, @recipientsList = 'bradchen@xxx.com'
-- EXEC dbo.uspQueryDbFileSizeSendtoDBA @chkTime = '2020-08-31 19:19:14', @ThresholdFreeSizeMB = 1024, @recipientsList = 'bradchen@xxx.com;xxxx@xxx.com'
-- =============================================
ALTER procedure [dbo].[uspQueryDbFileSizeSendtoDBA]
@chkTime nvarchar(20), @ThresholdFreeSizeMB int, @recipientsList varchar(500)
AS
SET NOCOUNT ON;


DECLARE @RowID INT = 1, @MaxRowID INT;
DECLARE @DbServer nvarchar(30)
		,@DbName nvarchar(30)
		,@DbFile nvarchar(30)
		,@FileId tinyint
		,@DbFileFullName nvarchar(100)
		,@SizeMB int
		,@UsedSizeMB int
		,@FreeSizeMB int
		,@FG nvarchar(30)

DECLARE @emailTitle nvarchar(100)
DECLARE @htmlbody nvarchar(MAX)
SET @htmlbody = ''

DECLARE @htmlTable nvarchar(MAX)
SET @htmlTable = '';
SET @htmlTable = N'<tr>'
				+ N'<td>SQL Server</td>'
				+ N'<td>Database</td>'
				+ N'<td>File Group</td>'
				+ N'<td>Db File Full Name</td>'
				+ N'<td>Size(MB)</td>'
				+ N'<td>UsedSize(MB)</td>'
				+ N'<td>FreeSize(MB)</td>'
				+ N'</tr>';

DECLARE @dbfiles Table
(
[RowID] int,
[DbServer] [nvarchar](30) NULL,
	[DbName] [nvarchar](30) NULL,
	[DbFile] [nvarchar](30) NULL,
	[FileId] [tinyint] NULL,
	[DbFileFullName] [nvarchar](100) NULL,
	[SizeMB] [int] NULL,
	[UsedSizeMB] [int] NULL,
	[FreeSizeMB] [int] NULL,
	[FG] [nvarchar](30) NULL
);

INSERT INTO @dbfiles ([RowID]
      ,[DbServer]
      ,[DbName]
      ,[DbFile]
      ,[FileId]
      ,[DbFileFullName]
      ,[SizeMB]
      ,[UsedSizeMB]
      ,[FreeSizeMB]
      ,[FG])
SELECT ROW_NUMBER() OVER (ORDER BY [DbServer],[DbName],[FileId]) AS [RowID]
	  ,[DbServer]
      ,[DbName]
      ,[DbFile]
      ,[FileId]
      ,[DbFileFullName]
      ,ROUND([SizeKB]/1024,0)
      ,ROUND([UsedSizeKB]/1024,0)
      ,ROUND([FreeSizeKB]/1024,0)
      ,[FG]
FROM dbo.DbFileSize where ChkTime = CAST(@chkTime as datetime) and FG <> 'PRIMARY';


SELECT @MaxRowID = MAX([RowID]) FROM @dbfiles
WHILE @RowID <= @MaxRowID
BEGIN
	select 
		@DbServer = [DbServer]
		,@DbName = [DbName]
		,@DbFile = [DbFile]
		,@FileId = [FileId]
		,@DbFileFullName = [DbFileFullName]
		,@SizeMB = [SizeMB]
		,@UsedSizeMB = [UsedSizeMB]
		,@FreeSizeMB = [FreeSizeMB]
		,@FG = [FG]
	from @dbfiles where [RowID] = @RowID
    
	If @FreeSizeMB < @ThresholdFreeSizeMB
	BEGIN  
		-- 小於1G
		SET  @htmlTable = @htmlTable 
					+ N'<tr style="font-weight: bold; color: red;">'
					+ N'<td>'+ @DbServer + N'</td>' 
					+ N'<td>'+ @DbName + N'</td>'  
					+ N'<td>'+ @FG + N'</td>'  
					+ N'<td>'+ @DbFileFullName + N'</td>' 
					+ N'<td>'+ CAST(@SizeMB as nvarchar) + N'</td>' 
					+ N'<td>'+ CAST(@UsedSizeMB as nvarchar) + N'</td>' 
					+ N'<td align="right">' + CAST(@FreeSizeMB as nvarchar)+ N'</td>'
					+ N'</tr>'
	END
	ELSE
	BEGIN  
		SET  @htmlTable = @htmlTable 
					+ N'<tr>'
					+ N'<td>'+ @DbServer + N'</td>' 
					+ N'<td>'+ @DbName + N'</td>'  
					+ N'<td>'+ @FG + N'</td>'  
					+ N'<td>'+ @DbFileFullName + N'</td>' 
					+ N'<td>'+ CAST(@SizeMB as nvarchar) + N'</td>' 
					+ N'<td>'+ CAST(@UsedSizeMB as nvarchar) + N'</td>' 
					+ N'<td align="right">' + CAST(@FreeSizeMB as nvarchar) + N'</td>' 
					+ N'</tr>'
	END

    SET @RowID = @RowID + 1;
END

SET @htmlbody =  N'<html>'
SET @htmlbody =  @htmlbody + N'檢查時間: ' + @chkTime + '<p>'
SET @htmlbody =  @htmlbody + N'資料庫檔案可用空間小於1G會出現紅色字體<p>'
SET @htmlbody =  @htmlbody + N'<table border="1">' + @htmlTable +  N'</table></html>'


--SET @emailTitle = 'Disk Free size - [' + @@SERVERNAME + ']';
SET @emailTitle = 'D18 SQL Server Datafile size';

--SELECT @htmlbody

    EXEC msdb.dbo.sp_send_dbmail
      @profile_name = NULL,
      @recipients = @recipientsList,
      @subject = @emailTitle,
      @body_format = 'HTML',
      @body = @htmlbody

GO


