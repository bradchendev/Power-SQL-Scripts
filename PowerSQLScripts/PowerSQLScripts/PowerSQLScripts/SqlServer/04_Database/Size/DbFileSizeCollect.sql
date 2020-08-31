

CREATE TABLE [dbo].[DbFileSize](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ChkTime] [datetime] NULL,
	[DbServer] [nvarchar](30) NULL,
	[DbName] [nvarchar](30) NULL,
	[DbFile] [nvarchar](30) NULL,
	[FileId] [tinyint] NULL,
	[DbFileFullName] [nvarchar](100) NULL,
	[SizeKB] [int] NULL,
	[UsedSizeKB] [int] NULL,
	[FreeSizeKB] [int] NULL,
	[FG] [nvarchar](30) NULL
) 
GO


-- =============================================
-- Author:        Brad Chen
-- Create date:    2020/8/31 
-- Description:    D18LocalDB File使用空間
-- Modified By    Modification Date    Modification Description

-- DECLARE @now nvarchar(20) = CONVERT(nvarchar(20), GETDATE(), 120);
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18local', @chkTime = @now
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18localOP20', @chkTime = @now
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18localOP30', @chkTime = @now
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18localOP40', @chkTime = @now
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18localSFC', @chkTime = @now
-- EXEC dbo.uspGetD18LocalDbFileSize @Db = 'd18localSMTLED', @chkTime = @now
-- =============================================
ALTER proc [dbo].[uspGetD18LocalDbFileSize]
@Db nvarchar(30), @chkTime nvarchar(20)
AS
set nocount on;
	INSERT INTO [dbo].[DbFileSize](
		[ChkTime]
		  ,[DbServer]
		  ,[DbName]
		  ,[DbFile]
		  ,[FileId]
		  ,[DbFileFullName]
		  ,[SizeKB]
		  ,[UsedSizeKB]
		  ,[FreeSizeKB]
		  ,[FG])
	EXEC( N'USE ['+ @Db + N']
	SELECT
	N'''+ @chkTime + N''' as [ChkTime],
	@@SERVERNAME as [DbServer],
	''' + @Db + N''' as [DbName],
	s.[name] AS [DbFile],
	s.[file_id] AS [FileId], 
	s.[physical_name] AS [DbFileFullName],
	s.[size] * CONVERT(float,8) AS [SizeKB],
	CAST(
		CASE s.[type] WHEN 2 THEN 0 
		ELSE CAST(FILEPROPERTY(s.[name], ''SpaceUsed'') AS float)* CONVERT(float,8) 
		END AS [float]
		) AS [UsedSpaceKB],
	s.[size] * CONVERT(float,8) - CAST(
		CASE s.[type] WHEN 2 THEN 0 
		ELSE CAST(FILEPROPERTY(s.[name], ''SpaceUsed'') AS float)* CONVERT(float,8) 
		END AS [float]
		) as [FreeKB],
	g.[name] as [FG]
	FROM sys.filegroups AS g
	INNER JOIN sys.master_files AS s 
		ON ((s.[type] = 2 or s.[type] = 0) 
		AND s.[database_id] = db_id() 
		AND (s.[drop_lsn] IS NULL)) 
		AND (s.[data_space_id]=g.[data_space_id])
	ORDER BY [FileId] ASC')  AT [D18LOCALDBA01];

	
