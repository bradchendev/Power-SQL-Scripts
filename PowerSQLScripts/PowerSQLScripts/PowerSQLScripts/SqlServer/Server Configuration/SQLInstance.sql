-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://bradctchen.blogspot.com/
-- Create date: 2021/8/20
-- Description:	SQL Server Instance information





        declare @MasterPath nvarchar(512)
        declare @LogPath nvarchar(512)
        declare @ErrorLog nvarchar(512)
        declare @ErrorLogPath nvarchar(512)
        declare @Slash varchar = convert(varchar, serverproperty('PathSeparator'))
        if (SERVERPROPERTY('EngineEdition') = 8 /* SQL Managed Instance */)
        begin
          select @MasterPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where file_id = 1
          select @LogPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where file_id = 2
        end
        else
        begin
          select @MasterPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where name=N'master'
          select @LogPath=substring(physical_name, 1, len(physical_name) - charindex(@Slash, reverse(physical_name))) from master.sys.database_files where name=N'mastlog'
        end
        select @ErrorLog=cast(SERVERPROPERTY(N'errorlogfilename') as nvarchar(512))
        select @ErrorLogPath=IIF(@ErrorLog IS NULL, N'', substring(@ErrorLog, 1, len(@ErrorLog) - charindex(@Slash, reverse(@ErrorLog))))
      


        declare @SmoRoot nvarchar(512)
        exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @SmoRoot OUTPUT
      


SELECT
CAST(case when 'a' <> 'A' then 1 else 0 end AS bit) AS [IsCaseSensitive],
@@MAX_PRECISION AS [MaxPrecision],
@ErrorLogPath AS [ErrorLogPath],
@SmoRoot AS [RootDirectory],
SERVERPROPERTY('PathSeparator') AS [PathSeparator],
CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit) AS [IsFullTextInstalled],
@LogPath AS [MasterDBLogPath],
@MasterPath AS [MasterDBPath],
SERVERPROPERTY(N'ProductVersion') AS [VersionString],
CAST(SERVERPROPERTY(N'Edition') AS sysname) AS [Edition],
CAST(SERVERPROPERTY(N'ProductLevel') AS sysname) AS [ProductLevel],
CAST(SERVERPROPERTY('IsSingleUser') AS bit) AS [IsSingleUser],
CAST(SERVERPROPERTY('EngineEdition') AS int) AS [EngineEdition],
convert(sysname, serverproperty(N'collation')) AS [Collation],
CAST(ISNULL(SERVERPROPERTY(N'MachineName'),N'') AS sysname) AS [NetName],
CAST(ISNULL(SERVERPROPERTY('IsClustered'),N'') AS bit) AS [IsClustered],
SERVERPROPERTY(N'ResourceVersion') AS [ResourceVersionString],
SERVERPROPERTY(N'ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
SERVERPROPERTY(N'CollationID') AS [CollationID],
SERVERPROPERTY(N'ComparisonStyle') AS [ComparisonStyle],
SERVERPROPERTY(N'SqlCharSet') AS [SqlCharSet],
SERVERPROPERTY(N'SqlCharSetName') AS [SqlCharSetName],
SERVERPROPERTY(N'SqlSortOrder') AS [SqlSortOrder],
SERVERPROPERTY(N'SqlSortOrderName') AS [SqlSortOrderName],
SERVERPROPERTY(N'BuildClrVersion') AS [BuildClrVersionString],
ISNULL(SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS'),N'') AS [ComputerNamePhysicalNetBIOS],
CAST(SERVERPROPERTY('IsPolyBaseInstalled') AS bit) AS [IsPolyBaseInstalled]


--IsCaseSensitive	MaxPrecision	ErrorLogPath	RootDirectory	PathSeparator	IsFullTextInstalled	MasterDBLogPath	MasterDBPath	VersionString	Edition	ProductLevel	IsSingleUser	EngineEdition	Collation	NetName	IsClustered	ResourceVersionString	ResourceLastUpdateDateTime	CollationID	ComparisonStyle	SqlCharSet	SqlCharSetName	SqlSortOrder	SqlSortOrderName	BuildClrVersionString	ComputerNamePhysicalNetBIOS	IsPolyBaseInstalled
--0	38	C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Log	C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL	\	1	C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA	C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA	15.0.4083.2	Developer Edition (64-bit)	RTM	0	3	Chinese_Taiwan_Stroke_CI_AS	1900304brad	0	15.00.4083	2020-11-02 19:24:58.290	53251	196609	13	cp950	0	bin_ascii_8	v4.0.30319	1900304BRAD	0