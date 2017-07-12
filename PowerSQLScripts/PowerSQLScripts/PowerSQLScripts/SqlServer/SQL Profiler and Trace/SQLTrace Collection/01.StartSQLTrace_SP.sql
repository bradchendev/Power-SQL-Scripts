-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/12
-- Description:	SQLTrace Collection Step 1

-- =============================================

USE [DBA]
GO

/****** Object:  StoredProcedure [Perf].[uspStartSQLTrace]    Script Date: 07/12/2017 11:36:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:        Brad Chen
-- Create date:    2016-10-17
-- Description:    啟動SQL Trace錄製trace for效能分析
-- Modified By    Modification Date    Modification Description
--
--  2016/10/17 add @StopTime若小於CAST( GETDATE() AS time)，則不執行SQL Trace
-- 2016/10/18 add @maxFileSize
--
--EXEC DBA.Perf.uspStartSQLTrace 
--			@folder='I:\DBA\SQLTraceFiles', 
--			@StopTime='20:35:00.000', 
--			@maxfilesize=200
-- =============================================

CREATE PROCEDURE [Perf].[uspStartSQLTrace]
	@folder nvarchar(100),
	@StopTime varchar(12),
	@maxfilesize bigint
AS
DECLARE @_folder nvarchar(100) 
DECLARE @_StopTime varchar(12) 
DECLARE @_maxfilesize bigint

SET @_folder = @folder
SET @_StopTime = @StopTime
SET @_maxfilesize = @maxfilesize

If CAST( @_StopTime AS time) > CAST( GETDATE() AS time)
	BEGIN
	declare @rc int
	declare @TraceID int
	
	declare @StopDatetime datetime
	declare @tracefile nvarchar(500)

	-- set @@StopDatetime = '2016-xx-xx 21:30:00.000'
	-- set @StopDatetime = CONVERT(VARCHAR(10), GETDATE(), 126) + ' 21:30:00.000'
	set @StopDatetime = CONVERT(VARCHAR(10), GETDATE(), 126) + ' ' + @_StopTime

	set @tracefile = N'' + @_folder + '\' + @@SERVERNAME + '_' + replace(convert(varchar(8), GETDATE(), 112)+convert(varchar(8), GETDATE(), 114), ':','')

	-- Please replace the text InsertFileNameHere, with an appropriate
	-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
	-- will be appended to the filename automatically. If you are writing from
	-- remote server to local drive, please use UNC path and make sure server has
	-- write access to your network share

	exec @rc = sp_trace_create @TraceID output, 2, @tracefile, @_maxfilesize, @StopDatetime
	if (@rc != 0) goto error

	-- Client side File and Table cannot be scripted

	-- Set the events
	declare @on bit
	set @on = 1
exec sp_trace_setevent @TraceID, 78, 9, @on
exec sp_trace_setevent @TraceID, 78, 10, @on
exec sp_trace_setevent @TraceID, 78, 14, @on
exec sp_trace_setevent @TraceID, 78, 11, @on
exec sp_trace_setevent @TraceID, 78, 12, @on
exec sp_trace_setevent @TraceID, 74, 9, @on
exec sp_trace_setevent @TraceID, 74, 10, @on
exec sp_trace_setevent @TraceID, 74, 14, @on
exec sp_trace_setevent @TraceID, 74, 11, @on
exec sp_trace_setevent @TraceID, 74, 12, @on
exec sp_trace_setevent @TraceID, 53, 9, @on
exec sp_trace_setevent @TraceID, 53, 10, @on
exec sp_trace_setevent @TraceID, 53, 14, @on
exec sp_trace_setevent @TraceID, 53, 11, @on
exec sp_trace_setevent @TraceID, 53, 12, @on
exec sp_trace_setevent @TraceID, 70, 9, @on
exec sp_trace_setevent @TraceID, 70, 10, @on
exec sp_trace_setevent @TraceID, 70, 14, @on
exec sp_trace_setevent @TraceID, 70, 11, @on
exec sp_trace_setevent @TraceID, 70, 12, @on
exec sp_trace_setevent @TraceID, 77, 9, @on
exec sp_trace_setevent @TraceID, 77, 10, @on
exec sp_trace_setevent @TraceID, 77, 14, @on
exec sp_trace_setevent @TraceID, 77, 11, @on
exec sp_trace_setevent @TraceID, 77, 12, @on
exec sp_trace_setevent @TraceID, 16, 15, @on
exec sp_trace_setevent @TraceID, 16, 12, @on
exec sp_trace_setevent @TraceID, 16, 9, @on
exec sp_trace_setevent @TraceID, 16, 13, @on
exec sp_trace_setevent @TraceID, 16, 10, @on
exec sp_trace_setevent @TraceID, 16, 14, @on
exec sp_trace_setevent @TraceID, 16, 11, @on
exec sp_trace_setevent @TraceID, 14, 1, @on
exec sp_trace_setevent @TraceID, 14, 9, @on
exec sp_trace_setevent @TraceID, 14, 10, @on
exec sp_trace_setevent @TraceID, 14, 14, @on
exec sp_trace_setevent @TraceID, 14, 11, @on
exec sp_trace_setevent @TraceID, 14, 12, @on
exec sp_trace_setevent @TraceID, 15, 15, @on
exec sp_trace_setevent @TraceID, 15, 16, @on
exec sp_trace_setevent @TraceID, 15, 9, @on
exec sp_trace_setevent @TraceID, 15, 17, @on
exec sp_trace_setevent @TraceID, 15, 10, @on
exec sp_trace_setevent @TraceID, 15, 14, @on
exec sp_trace_setevent @TraceID, 15, 18, @on
exec sp_trace_setevent @TraceID, 15, 11, @on
exec sp_trace_setevent @TraceID, 15, 12, @on
exec sp_trace_setevent @TraceID, 15, 13, @on
exec sp_trace_setevent @TraceID, 17, 1, @on
exec sp_trace_setevent @TraceID, 17, 9, @on
exec sp_trace_setevent @TraceID, 17, 10, @on
exec sp_trace_setevent @TraceID, 17, 14, @on
exec sp_trace_setevent @TraceID, 17, 11, @on
exec sp_trace_setevent @TraceID, 17, 12, @on
exec sp_trace_setevent @TraceID, 100, 7, @on
exec sp_trace_setevent @TraceID, 100, 8, @on
exec sp_trace_setevent @TraceID, 100, 64, @on
exec sp_trace_setevent @TraceID, 100, 1, @on
exec sp_trace_setevent @TraceID, 100, 9, @on
exec sp_trace_setevent @TraceID, 100, 41, @on
exec sp_trace_setevent @TraceID, 100, 49, @on
exec sp_trace_setevent @TraceID, 100, 6, @on
exec sp_trace_setevent @TraceID, 100, 10, @on
exec sp_trace_setevent @TraceID, 100, 14, @on
exec sp_trace_setevent @TraceID, 100, 26, @on
exec sp_trace_setevent @TraceID, 100, 34, @on
exec sp_trace_setevent @TraceID, 100, 50, @on
exec sp_trace_setevent @TraceID, 100, 66, @on
exec sp_trace_setevent @TraceID, 100, 3, @on
exec sp_trace_setevent @TraceID, 100, 11, @on
exec sp_trace_setevent @TraceID, 100, 35, @on
exec sp_trace_setevent @TraceID, 100, 51, @on
exec sp_trace_setevent @TraceID, 100, 4, @on
exec sp_trace_setevent @TraceID, 100, 12, @on
exec sp_trace_setevent @TraceID, 100, 60, @on
exec sp_trace_setevent @TraceID, 10, 7, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 31, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 48, @on
exec sp_trace_setevent @TraceID, 10, 64, @on
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 25, @on
exec sp_trace_setevent @TraceID, 10, 41, @on
exec sp_trace_setevent @TraceID, 10, 49, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 26, @on
exec sp_trace_setevent @TraceID, 10, 34, @on
exec sp_trace_setevent @TraceID, 10, 50, @on
exec sp_trace_setevent @TraceID, 10, 66, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 10, 51, @on
exec sp_trace_setevent @TraceID, 10, 4, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 60, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 11, 7, @on
exec sp_trace_setevent @TraceID, 11, 8, @on
exec sp_trace_setevent @TraceID, 11, 64, @on
exec sp_trace_setevent @TraceID, 11, 1, @on
exec sp_trace_setevent @TraceID, 11, 9, @on
exec sp_trace_setevent @TraceID, 11, 25, @on
exec sp_trace_setevent @TraceID, 11, 41, @on
exec sp_trace_setevent @TraceID, 11, 49, @on
exec sp_trace_setevent @TraceID, 11, 2, @on
exec sp_trace_setevent @TraceID, 11, 6, @on
exec sp_trace_setevent @TraceID, 11, 10, @on
exec sp_trace_setevent @TraceID, 11, 14, @on
exec sp_trace_setevent @TraceID, 11, 26, @on
exec sp_trace_setevent @TraceID, 11, 34, @on
exec sp_trace_setevent @TraceID, 11, 50, @on
exec sp_trace_setevent @TraceID, 11, 66, @on
exec sp_trace_setevent @TraceID, 11, 3, @on
exec sp_trace_setevent @TraceID, 11, 11, @on
exec sp_trace_setevent @TraceID, 11, 35, @on
exec sp_trace_setevent @TraceID, 11, 51, @on
exec sp_trace_setevent @TraceID, 11, 4, @on
exec sp_trace_setevent @TraceID, 11, 12, @on
exec sp_trace_setevent @TraceID, 11, 60, @on
exec sp_trace_setevent @TraceID, 43, 7, @on
exec sp_trace_setevent @TraceID, 43, 15, @on
exec sp_trace_setevent @TraceID, 43, 8, @on
exec sp_trace_setevent @TraceID, 43, 48, @on
exec sp_trace_setevent @TraceID, 43, 64, @on
exec sp_trace_setevent @TraceID, 43, 1, @on
exec sp_trace_setevent @TraceID, 43, 9, @on
exec sp_trace_setevent @TraceID, 43, 41, @on
exec sp_trace_setevent @TraceID, 43, 49, @on
exec sp_trace_setevent @TraceID, 43, 2, @on
exec sp_trace_setevent @TraceID, 43, 10, @on
exec sp_trace_setevent @TraceID, 43, 26, @on
exec sp_trace_setevent @TraceID, 43, 34, @on
exec sp_trace_setevent @TraceID, 43, 50, @on
exec sp_trace_setevent @TraceID, 43, 66, @on
exec sp_trace_setevent @TraceID, 43, 3, @on
exec sp_trace_setevent @TraceID, 43, 11, @on
exec sp_trace_setevent @TraceID, 43, 35, @on
exec sp_trace_setevent @TraceID, 43, 51, @on
exec sp_trace_setevent @TraceID, 43, 4, @on
exec sp_trace_setevent @TraceID, 43, 12, @on
exec sp_trace_setevent @TraceID, 43, 28, @on
exec sp_trace_setevent @TraceID, 43, 60, @on
exec sp_trace_setevent @TraceID, 43, 5, @on
exec sp_trace_setevent @TraceID, 43, 13, @on
exec sp_trace_setevent @TraceID, 43, 29, @on
exec sp_trace_setevent @TraceID, 43, 6, @on
exec sp_trace_setevent @TraceID, 43, 14, @on
exec sp_trace_setevent @TraceID, 43, 22, @on
exec sp_trace_setevent @TraceID, 43, 62, @on
exec sp_trace_setevent @TraceID, 45, 7, @on
exec sp_trace_setevent @TraceID, 45, 55, @on
exec sp_trace_setevent @TraceID, 45, 8, @on
exec sp_trace_setevent @TraceID, 45, 16, @on
exec sp_trace_setevent @TraceID, 45, 48, @on
exec sp_trace_setevent @TraceID, 45, 64, @on
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 9, @on
exec sp_trace_setevent @TraceID, 45, 17, @on
exec sp_trace_setevent @TraceID, 45, 25, @on
exec sp_trace_setevent @TraceID, 45, 41, @on
exec sp_trace_setevent @TraceID, 45, 49, @on
exec sp_trace_setevent @TraceID, 45, 10, @on
exec sp_trace_setevent @TraceID, 45, 18, @on
exec sp_trace_setevent @TraceID, 45, 26, @on
exec sp_trace_setevent @TraceID, 45, 34, @on
exec sp_trace_setevent @TraceID, 45, 50, @on
exec sp_trace_setevent @TraceID, 45, 66, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 35, @on
exec sp_trace_setevent @TraceID, 45, 51, @on
exec sp_trace_setevent @TraceID, 45, 4, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 28, @on
exec sp_trace_setevent @TraceID, 45, 60, @on
exec sp_trace_setevent @TraceID, 45, 5, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 29, @on
exec sp_trace_setevent @TraceID, 45, 61, @on
exec sp_trace_setevent @TraceID, 45, 6, @on
exec sp_trace_setevent @TraceID, 45, 14, @on
exec sp_trace_setevent @TraceID, 45, 22, @on
exec sp_trace_setevent @TraceID, 45, 62, @on
exec sp_trace_setevent @TraceID, 45, 15, @on
exec sp_trace_setevent @TraceID, 44, 7, @on
exec sp_trace_setevent @TraceID, 44, 55, @on
exec sp_trace_setevent @TraceID, 44, 8, @on
exec sp_trace_setevent @TraceID, 44, 64, @on
exec sp_trace_setevent @TraceID, 44, 1, @on
exec sp_trace_setevent @TraceID, 44, 9, @on
exec sp_trace_setevent @TraceID, 44, 41, @on
exec sp_trace_setevent @TraceID, 44, 49, @on
exec sp_trace_setevent @TraceID, 44, 10, @on
exec sp_trace_setevent @TraceID, 44, 26, @on
exec sp_trace_setevent @TraceID, 44, 34, @on
exec sp_trace_setevent @TraceID, 44, 50, @on
exec sp_trace_setevent @TraceID, 44, 66, @on
exec sp_trace_setevent @TraceID, 44, 3, @on
exec sp_trace_setevent @TraceID, 44, 11, @on
exec sp_trace_setevent @TraceID, 44, 35, @on
exec sp_trace_setevent @TraceID, 44, 51, @on
exec sp_trace_setevent @TraceID, 44, 4, @on
exec sp_trace_setevent @TraceID, 44, 12, @on
exec sp_trace_setevent @TraceID, 44, 28, @on
exec sp_trace_setevent @TraceID, 44, 60, @on
exec sp_trace_setevent @TraceID, 44, 5, @on
exec sp_trace_setevent @TraceID, 44, 29, @on
exec sp_trace_setevent @TraceID, 44, 61, @on
exec sp_trace_setevent @TraceID, 44, 6, @on
exec sp_trace_setevent @TraceID, 44, 14, @on
exec sp_trace_setevent @TraceID, 44, 22, @on
exec sp_trace_setevent @TraceID, 44, 30, @on
exec sp_trace_setevent @TraceID, 44, 62, @on
exec sp_trace_setevent @TraceID, 71, 9, @on
exec sp_trace_setevent @TraceID, 71, 10, @on
exec sp_trace_setevent @TraceID, 71, 14, @on
exec sp_trace_setevent @TraceID, 71, 11, @on
exec sp_trace_setevent @TraceID, 71, 12, @on
exec sp_trace_setevent @TraceID, 12, 7, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 31, @on
exec sp_trace_setevent @TraceID, 12, 8, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 48, @on
exec sp_trace_setevent @TraceID, 12, 64, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 41, @on
exec sp_trace_setevent @TraceID, 12, 49, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 26, @on
exec sp_trace_setevent @TraceID, 12, 50, @on
exec sp_trace_setevent @TraceID, 12, 66, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 35, @on
exec sp_trace_setevent @TraceID, 12, 51, @on
exec sp_trace_setevent @TraceID, 12, 4, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 60, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 13, 7, @on
exec sp_trace_setevent @TraceID, 13, 8, @on
exec sp_trace_setevent @TraceID, 13, 64, @on
exec sp_trace_setevent @TraceID, 13, 1, @on
exec sp_trace_setevent @TraceID, 13, 9, @on
exec sp_trace_setevent @TraceID, 13, 41, @on
exec sp_trace_setevent @TraceID, 13, 49, @on
exec sp_trace_setevent @TraceID, 13, 6, @on
exec sp_trace_setevent @TraceID, 13, 10, @on
exec sp_trace_setevent @TraceID, 13, 14, @on
exec sp_trace_setevent @TraceID, 13, 26, @on
exec sp_trace_setevent @TraceID, 13, 50, @on
exec sp_trace_setevent @TraceID, 13, 66, @on
exec sp_trace_setevent @TraceID, 13, 3, @on
exec sp_trace_setevent @TraceID, 13, 11, @on
exec sp_trace_setevent @TraceID, 13, 35, @on
exec sp_trace_setevent @TraceID, 13, 51, @on
exec sp_trace_setevent @TraceID, 13, 4, @on
exec sp_trace_setevent @TraceID, 13, 12, @on
exec sp_trace_setevent @TraceID, 13, 60, @on
exec sp_trace_setevent @TraceID, 73, 9, @on
exec sp_trace_setevent @TraceID, 73, 10, @on
exec sp_trace_setevent @TraceID, 73, 14, @on
exec sp_trace_setevent @TraceID, 73, 11, @on
exec sp_trace_setevent @TraceID, 73, 12, @on
exec sp_trace_setevent @TraceID, 19, 1, @on
exec sp_trace_setevent @TraceID, 19, 9, @on
exec sp_trace_setevent @TraceID, 19, 10, @on
exec sp_trace_setevent @TraceID, 19, 14, @on
exec sp_trace_setevent @TraceID, 19, 11, @on
exec sp_trace_setevent @TraceID, 19, 12, @on
exec sp_trace_setevent @TraceID, 50, 15, @on
exec sp_trace_setevent @TraceID, 50, 1, @on
exec sp_trace_setevent @TraceID, 50, 9, @on
exec sp_trace_setevent @TraceID, 50, 10, @on
exec sp_trace_setevent @TraceID, 50, 14, @on
exec sp_trace_setevent @TraceID, 50, 11, @on
exec sp_trace_setevent @TraceID, 50, 12, @on
exec sp_trace_setevent @TraceID, 50, 13, @on
exec sp_trace_setevent @TraceID, 182, 1, @on
exec sp_trace_setevent @TraceID, 182, 9, @on
exec sp_trace_setevent @TraceID, 182, 10, @on
exec sp_trace_setevent @TraceID, 182, 14, @on
exec sp_trace_setevent @TraceID, 182, 11, @on
exec sp_trace_setevent @TraceID, 182, 12, @on
exec sp_trace_setevent @TraceID, 181, 1, @on
exec sp_trace_setevent @TraceID, 181, 9, @on
exec sp_trace_setevent @TraceID, 181, 10, @on
exec sp_trace_setevent @TraceID, 181, 14, @on
exec sp_trace_setevent @TraceID, 181, 11, @on
exec sp_trace_setevent @TraceID, 181, 12, @on
exec sp_trace_setevent @TraceID, 186, 1, @on
exec sp_trace_setevent @TraceID, 186, 9, @on
exec sp_trace_setevent @TraceID, 186, 10, @on
exec sp_trace_setevent @TraceID, 186, 14, @on
exec sp_trace_setevent @TraceID, 186, 11, @on
exec sp_trace_setevent @TraceID, 186, 12, @on
exec sp_trace_setevent @TraceID, 185, 1, @on
exec sp_trace_setevent @TraceID, 185, 9, @on
exec sp_trace_setevent @TraceID, 185, 10, @on
exec sp_trace_setevent @TraceID, 185, 14, @on
exec sp_trace_setevent @TraceID, 185, 11, @on
exec sp_trace_setevent @TraceID, 185, 12, @on
exec sp_trace_setevent @TraceID, 184, 9, @on
exec sp_trace_setevent @TraceID, 184, 10, @on
exec sp_trace_setevent @TraceID, 184, 14, @on
exec sp_trace_setevent @TraceID, 184, 11, @on
exec sp_trace_setevent @TraceID, 184, 12, @on
exec sp_trace_setevent @TraceID, 183, 12, @on
exec sp_trace_setevent @TraceID, 183, 9, @on
exec sp_trace_setevent @TraceID, 183, 10, @on
exec sp_trace_setevent @TraceID, 183, 14, @on
exec sp_trace_setevent @TraceID, 183, 11, @on
exec sp_trace_setevent @TraceID, 188, 1, @on
exec sp_trace_setevent @TraceID, 188, 9, @on
exec sp_trace_setevent @TraceID, 188, 10, @on
exec sp_trace_setevent @TraceID, 188, 14, @on
exec sp_trace_setevent @TraceID, 188, 11, @on
exec sp_trace_setevent @TraceID, 188, 12, @on
exec sp_trace_setevent @TraceID, 187, 1, @on
exec sp_trace_setevent @TraceID, 187, 9, @on
exec sp_trace_setevent @TraceID, 187, 10, @on
exec sp_trace_setevent @TraceID, 187, 14, @on
exec sp_trace_setevent @TraceID, 187, 11, @on
exec sp_trace_setevent @TraceID, 187, 12, @on
exec sp_trace_setevent @TraceID, 192, 1, @on
exec sp_trace_setevent @TraceID, 192, 9, @on
exec sp_trace_setevent @TraceID, 192, 10, @on
exec sp_trace_setevent @TraceID, 192, 14, @on
exec sp_trace_setevent @TraceID, 192, 11, @on
exec sp_trace_setevent @TraceID, 192, 12, @on
exec sp_trace_setevent @TraceID, 191, 1, @on
exec sp_trace_setevent @TraceID, 191, 9, @on
exec sp_trace_setevent @TraceID, 191, 10, @on
exec sp_trace_setevent @TraceID, 191, 14, @on
exec sp_trace_setevent @TraceID, 191, 11, @on
exec sp_trace_setevent @TraceID, 191, 12, @on


	-- Set the Filters
	declare @intfilter int
	declare @bigintfilter bigint

	-- Set the trace status to start
	exec sp_trace_setstatus @TraceID, 1

	-- display trace id for future references
	select TraceID=@TraceID
	goto finish

	error: 
	select ErrorCode=@rc

	finish: 
	END;
ELSE
	BEGIN
	PRINT 'Parameter @StopTime < CAST( GETDATE() AS time), do not create SQL Trace'
	END;


GO


