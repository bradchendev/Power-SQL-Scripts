USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspMonSession]    Script Date: 2021/6/18 下午 06:55:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Brad Chen
-- Create date:    2021/6/18 
-- Description:    monitor running session
-- Modified By    Modification Date    Modification Description

-- EXEC [dbo].[uspMonSession] @BlocingOnly = 0, @mailRecipList = 'bradchen@xxxx.com;user2@xxxx.com'
-- =============================================

ALTER PROC [dbo].[uspMonSession]
@BlocingOnly bit, @mailRecipList varchar(256)
AS
set nocount on;
declare @chkTime nvarchar(20) = GETDATE()
declare @mailTitle nvarchar(100)
declare @blockcnt int
-- detect long running queyr > 180 sec
declare @longRunQuryThreshold int = 180

set @mailTitle = 'SQL Server Session Monitoring'

If @BlocingOnly = 1
begin
	select @blockcnt = count(*) 
	from sys.dm_exec_requests req 
	where blocking_session_id > 0;
end

If (@BlocingOnly = 0 or @blockcnt > 0)
begin

	DECLARE @RowID INT = 1, @MaxRowID INT;

	DECLARE @session_id smallint, 
			@duration int,
			@blocker smallint, 
			@se_status nvarchar(30)=N'', 
			@req_status nvarchar(30)=N'', 
			@req_waitType nvarchar(60)=N'', 
			@req_waitTime int, 
			@se_host nvarchar(128)=N'', 
			@se_prog nvarchar(128)=N'', 
			@login_name nvarchar(128)=N'', 
			@last_request_start_time datetime, 
			@last_request_end_time datetime, 
			@req_ParentQuery nvarchar(128)=N'', 
			@req_Statement nvarchar(128)=N'', 
			@con_most_recent_sql nvarchar(128)=N''


	declare @mailhtmlbody nvarchar(MAX)=N'';
	--SET @mailhtmlbody = '';
	
	DECLARE @htmlTable nvarchar(MAX)=N'';
	SET @htmlTable = N'<tr>'
				+ N'<td>se_id</td>'
				+ N'<td>duration(sec)</td>'
				+ N'<td>blocker</td>'
				+ N'<td>se_status</td>'
				+ N'<td>req_status</td>'
				+ N'<td>req_waitType</td>'
				+ N'<td>req_waitTime</td>'
				+ N'<td>client</td>'
				+ N'<td>prog</td>'
				+ N'<td>login</td>'
				+ N'<td>lastReqStartTime</td>'
				+ N'<td>lastReqEndTime</td>'
				+ N'<td>reqParentQuery</td>'
				+ N'<td>reqStatement</td>'
				+ N'<td>con_most_recent_sql</td>'
				+ N'</tr>';

	DECLARE @curSessions Table
	(
	[RowID] int,
	[session_id] [smallint] NOT NULL,
	[blocker] [smallint] NULL,
	[se_status] [nvarchar](30) NOT NULL,
	[req_status] [nvarchar](30) NULL,
	[req_waitType] [nvarchar](60) NULL,
	[req_waitTime] [int] NULL,
	[se_host] [nvarchar](128) NULL,
	[se_prog] [nvarchar](128) NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[last_request_start_time] [datetime] NOT NULL,
	[last_request_end_time] [datetime] NULL,
	[req_ParentQuery] [nvarchar](128) NULL,
	[req_Statement] [nvarchar](128) NULL,
	[con_most_recent_sql] [nvarchar](128) NULL
	);


	INSERT INTO @curSessions (
	[RowID],
	[session_id],
	[blocker] ,
	[se_status] ,
	[req_status],
	[req_waitType],
	[req_waitTime],
	[se_host],
	[se_prog],
	[login_name],
	[last_request_start_time],
	[last_request_end_time],
	[req_ParentQuery],
	[req_Statement],
	[con_most_recent_sql])
	SELECT 
	ROW_NUMBER() OVER (ORDER BY req.cpu_time DESC) AS [RowID],
	se.session_id, 
	req.blocking_session_id as [blocker],
	se.status as [se_status],
	req.status as [req_status],
	req.wait_type as [req_waitType],
	req.wait_time as [req_waitTime],
	se.host_name as [se_host],
	se.program_name as [se_prog],
	se.login_name,
	se.last_request_start_time,
	se.last_request_end_time,
	SUBSTRING(st.text,1, 64) as [req_ParentQuery],
	SUBSTRING(st.text, (req.statement_start_offset/2)+1,64) AS req_Statement,
	SUBSTRING(st2.text,1, 64) as [con_most_recent_sql]
	from sys.dm_exec_sessions se
	inner Join sys.dm_exec_connections con on se.session_id=con.session_id and se.is_user_process = 1
	Left join sys.dm_exec_requests req on req.session_id = se.session_id
	OUTER APPLY sys.dm_exec_sql_text(req.sql_handle) AS st
	OUTER APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle) AS st2


	Declare @longRunQury int = 0
	select @longRunQury = count(*) from @curSessions where req_status is not null
	and datediff(SECOND,last_request_start_time, getdate()) > @longRunQuryThreshold;



	SELECT @MaxRowID = MAX([RowID]) FROM @curSessions

	WHILE (@RowID <= @MaxRowID AND @RowID <= 50)
	BEGIN
		--select 
		--session_id, 
		--blocker , 
		--se_status , 
		--req_status, 
		--req_waitType, 
		--req_waitTime, 
		--se_host, 
		--se_prog, 
		--login_name, 
		--last_request_start_time, 
		--last_request_end_time, 
		--req_ParentQuery, 
		--req_ParentQuery, 
		--con_most_recent_sql 
		--from @curSessions 
		--where [RowID] = @RowID;

		select 
			@session_id = session_id, 
			@duration = datediff(SECOND,last_request_start_time, getdate()),
			@blocker = blocker , 
			@se_status = se_status , 
			@req_status = req_status, 
			@req_waitType = req_waitType, 
			@req_waitTime = req_waitTime, 
			@se_host = se_host, 
			@se_prog = se_prog, 
			@login_name = login_name, 
			@last_request_start_time = last_request_start_time, 
			@last_request_end_time = last_request_end_time, 
			@req_ParentQuery = isnull(req_ParentQuery, N'NULL'), 
			@req_Statement = isnull(req_ParentQuery, N'NULL'), 
			@con_most_recent_sql = isnull(con_most_recent_sql, N'NULL')
		from @curSessions 
		where [RowID] = @RowID;
 
		SET  @htmlTable = CONCAT(@htmlTable
					, N'<tr>'
					, N'<td>', CAST(@session_id as nvarchar) , N'</td>' 
					, N'<td>', CAST(@duration as nvarchar) , N'</td>' 
					, N'<td>', CAST(@blocker as nvarchar) , N'</td>' 
					, N'<td>', @se_status , N'</td>'  
					, N'<td>', @req_status , N'</td>' 
					, N'<td>', @req_waitType , N'</td>' 
					, N'<td>', CAST(@req_waitTime as nvarchar) , N'</td>' 
					, N'<td>', @se_host , N'</td>' 
					, N'<td>', @se_prog , N'</td>' 
					, N'<td>', @login_name , N'</td>' 
					, N'<td>', CONVERT(nvarchar(23), @last_request_start_time, 121) , N'</td>' 
					, N'<td>', CONVERT(nvarchar(23), @last_request_end_time, 121) , N'</td>' 
					, N'<td>', @req_ParentQuery , N'</td>' 
					, N'<td>', @req_Statement , N'</td>' 
					, N'<td>', @con_most_recent_sql , N'</td>' 
					, N'</tr>')
		SET @RowID = @RowID + 1;
		--SELECT LEN(@htmlTable),@htmlTable;
	END

	SET @mailhtmlbody =  N'<html>'
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'檢查時間: ' , CONVERT(nvarchar(23), @chkTime, 121) , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'主機名稱: ' , @@SERVERNAME , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'SQL版本: ' , Substring(@@VERSION,11, 15) , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'連線數量: ' , CAST(@MaxRowID as nvarchar) , N'<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'執行超過', CAST(@longRunQuryThreshold as nvarchar ) , N'秒,共有 ',CAST(@longRunQury as nvarchar ),N' 條連線' );
	If @MaxRowID > 100
		SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'連線數量超過50條，以下僅列出前50<p>');
	SET @mailhtmlbody =  CONCAT(@mailhtmlbody , N'<table border="1">' , @htmlTable ,  N'</table></html>');

	--SELECT @mailhtmlbody;

    EXEC msdb.dbo.sp_send_dbmail
      @profile_name = NULL,
      @recipients = @mailRecipList,
      @subject = @mailTitle,
      @body_format = 'HTML',
      @body = @mailhtmlbody

end
