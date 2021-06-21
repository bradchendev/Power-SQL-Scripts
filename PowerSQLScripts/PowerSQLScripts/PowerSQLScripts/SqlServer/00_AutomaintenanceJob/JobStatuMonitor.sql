USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspMonJobStatusHist]    Script Date: 2021/6/21 下午 02:54:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Brad Chen
-- Create date:    2021/6/21
-- Description:    Job run duration History
-- Modified By    Modification Date    Modification Description

--Create view [dbo].[vwETLJobhist]
--AS
--SELECT [RunDateTime], 
--[Local2DW_OP20] AS [Local2DW_OP20], 
--[Local2DW_OP30] AS [Local2DW_OP30], 
--[Local2DW_OP40] AS [Local2DW_OP40], 
--[Local2DW_OP50] AS [Local2DW_OP50], 
--[Local2DW_OP70] AS [Local2DW_OP70], 
--[Local2DW_SMNF] AS [Local2DW_SMNF], 
--[Local2DW_SEFF] AS [Local2DW_SEFF], 
--[Local2DW_SEDF] AS [Local2DW_SEDF]  
--FROM   
--(
--	SELECT v.[JobName], v.[RunDateTime] ,v.[run_duration]
--	FROM 
--	(
--		select j.name as [JobName],
--		msdb.dbo.agent_datetime(run_date, run_time) as [RunDateTime],
--		STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(jh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':') [run_duration]
--		from msdb.dbo.sysjobhistory jh join msdb.dbo.sysjobs j on jh.job_id = j.job_id
--		where jh.step_name='(Job outcome)' and j.name like 'Local%'
--	) v	
--) p  
--	PIVOT  
--	(  
--		MAX ([run_duration])
--		FOR [JobName] IN  
--		(  [Local2DW_OP20] , [Local2DW_OP30] ,[Local2DW_OP40] ,[Local2DW_OP50] ,[Local2DW_OP70] , [Local2DW_SMNF] , [Local2DW_SEFF] , [Local2DW_SEDF] )  
--	) AS pvt  
----ORDER BY pvt.[RunDateTime] DESC;
--GO


-- EXEC [dbo].[uspMonJobStatusHist] @mailRecipList = 'bradchen@systex.com'
-- EXEC [dbo].[uspMonJobStatusHist] @mailRecipList = 'bradchen@systex.com;shawnlai@systex.com'
-- =============================================

ALTER PROC [dbo].[uspMonJobStatusHist]
 @mailRecipList varchar(256)
AS
set nocount on;
declare @chkTime nvarchar(20) = GETDATE()
declare @mailTitle nvarchar(100)

set @mailTitle = N'SQL Server Job Status Monitoring - ' + @@SERVERNAME

	DECLARE @RowID INT = 1, @MaxRowID INT;

	DECLARE @RunDateTime [datetime],
	@Local2DW_OP20 [varchar](19)=N'',
	@Local2DW_OP30 [varchar](19)=N'',
	@Local2DW_OP40 [varchar](19)=N'',
	@Local2DW_OP50 [varchar](19)=N'',
	@Local2DW_OP70 [varchar](19)=N'',
	@Local2DW_SMNF [varchar](19)=N'',
	@Local2DW_SEFF [varchar](19)=N'',
	@Local2DW_SEDF [varchar](19)=N''


	declare @mailhtmlbody nvarchar(MAX)=N'';
	--SET @mailhtmlbody = '';
	
	DECLARE @htmlTable nvarchar(MAX)=N'';
	SET @htmlTable =  CONCAT(N'<tr>'
				, N'<td>RunDateTime</td>'
				, N'<td>Local2DW_OP20</td>'
				, N'<td>Local2DW_OP30</td>'
				, N'<td>Local2DW_OP40</td>'
				, N'<td>Local2DW_OP50</td>'
				, N'<td>Local2DW_OP70</td>'
				, N'<td>Local2DW_SMNF</td>'
				, N'<td>Local2DW_SEFF</td>'
				, N'<td>Local2DW_SEDF</td>'
				, N'</tr>');

	DECLARE @JobTable Table
	(
	[RowID] int,
	[RunDateTime] [datetime] NULL,
	[Local2DW_OP20] [varchar](19) NULL,
	[Local2DW_OP30] [varchar](19) NULL,
	[Local2DW_OP40] [varchar](19) NULL,
	[Local2DW_OP50] [varchar](19) NULL,
	[Local2DW_OP70] [varchar](19) NULL,
	[Local2DW_SMNF] [varchar](19) NULL,
	[Local2DW_SEFF] [varchar](19) NULL,
	[Local2DW_SEDF] [varchar](19) NULL
	);


	INSERT INTO @JobTable (
				[RowID],
				[RunDateTime] ,
				[Local2DW_OP20] ,
				[Local2DW_OP30],
				[Local2DW_OP40] ,
				[Local2DW_OP50] ,
				[Local2DW_OP70],
				[Local2DW_SMNF],
				[Local2DW_SEFF] ,
				[Local2DW_SEDF])
	SELECT 
	ROW_NUMBER() OVER (ORDER BY [RunDateTime] DESC) AS [RowID],
	[RunDateTime] ,
	[Local2DW_OP20] ,
	[Local2DW_OP30],
	[Local2DW_OP40] ,
	[Local2DW_OP50] ,
	[Local2DW_OP70],
	[Local2DW_SMNF],
	[Local2DW_SEFF] ,
	[Local2DW_SEDF] 
	from DBA.dbo.vwETLJobhist WHERE [RunDateTime] >= CAST( GETDATE() AS DATE) ORDER BY [RunDateTime] DESC


	SELECT @MaxRowID = MAX([RowID]) FROM @JobTable

	WHILE (@RowID <= @MaxRowID AND @RowID <= 50)
	BEGIN

		select 
			@RunDateTime = RunDateTime,
			@Local2DW_OP20 = Local2DW_OP20,
			@Local2DW_OP30 = Local2DW_OP30,
			@Local2DW_OP40 = Local2DW_OP40,
			@Local2DW_OP50 = Local2DW_OP50,
			@Local2DW_OP70 = Local2DW_OP70,
			@Local2DW_SMNF = Local2DW_SMNF,
			@Local2DW_SEFF = Local2DW_SEFF,
			@Local2DW_SEDF = Local2DW_SEDF
		from @JobTable 
		where [RowID] = @RowID;
 
		SET  @htmlTable = CONCAT(@htmlTable
					, N'<tr>'
					, N'<td>', CONVERT(nvarchar(23), @RunDateTime, 121) , N'</td>' 
					, N'<td>', @Local2DW_OP20 , N'</td>' 
					, N'<td>', @Local2DW_OP30 , N'</td>' 
					, N'<td>', @Local2DW_OP40 , N'</td>' 
					, N'<td>', @Local2DW_OP50 , N'</td>' 
					, N'<td>', @Local2DW_OP70 , N'</td>' 
					, N'<td>', @Local2DW_SMNF , N'</td>' 
					, N'<td>', @Local2DW_SEFF , N'</td>' 
					, N'<td>', @Local2DW_SEDF , N'</td>' 
					, N'</tr>')
		SET @RowID = @RowID + 1;
		--SELECT LEN(@htmlTable),@htmlTable;
	END

	
	SET @mailhtmlbody =  N'<html>'
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'檢查時間: ' , CONVERT(nvarchar(23), @chkTime, 121) , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'主機名稱: ' , @@SERVERNAME , N'  SQL版本: ' , Substring(@@VERSION,11, 15) , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'目前Job執行時間，格式為 day:hour:minutes:second ' , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'<table border="1">' , @htmlTable ,  N'</table></html>');

	--SELECT @mailhtmlbody;

    EXEC msdb.dbo.sp_send_dbmail
      @profile_name = NULL,
      @recipients = @mailRecipList,
      @subject = @mailTitle,
      @body_format = 'HTML',
      @body = @mailhtmlbody
