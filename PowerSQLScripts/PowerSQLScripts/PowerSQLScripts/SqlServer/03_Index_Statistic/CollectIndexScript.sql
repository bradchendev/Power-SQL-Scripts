-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/5/25
-- Description:	collect all Index in DB
-- 
-- Modified date: 2018-06-22 
--  1.Fix bug left join sys.filegroups and left join sys.partition_schemes
--  2.add IndexName column
-- =============================================


USE [DBA]
GO
CREATE TABLE [dbo].[IndexBackup](
	[Sn] [int] IDENTITY(1,1) PRIMARY KEY,
	[CollectDateTime] [datetime] NULL,
	[DB] [nvarchar](50) NULL,
	[SchemaName] [nvarchar](50) NULL,
	[TableName] [nvarchar](200) NULL,
	[Is_ms_shipped] [bit] NULL,
	[IndexName] [nvarchar](500) NULL,
	[CreateIndexSql] [nvarchar](max) NULL
	);



USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspCollectIndex]    Script Date: 06/22/2018 12:43:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--EXEC DBA.dbo.uspCollectIndex;
--Create by Brad Chen
CREATE PROC [dbo].[uspCollectIndex]
AS
SET NOCOUNT ON;
DECLARE @DBname sysname;
DECLARE @sqlcmd nvarchar(4000);
DECLARE @sqlDelhist nvarchar(4000);
DECLARE @RowID INT = 1, @MaxRowID INT;

CREATE TABLE #DB (  RowID int, name sysname );

INSERT INTO #DB ( RowID,name)
SELECT ROW_NUMBER() 
        OVER (ORDER BY name) AS Row, name
FROM sys.databases where [state] =0 and name not in ('master','tempdb','msdb','model');

SELECT @MaxRowID = MAX(RowID) FROM #DB
WHILE @RowID <= @MaxRowID
BEGIN

	select @DBname = name from #DB where RowID = @RowID

	PRINT @DBname

	set @sqlcmd = 
	'use [' + @DBname + '];
	declare @CollectTime datetime = GETDATE();
	declare @DB varchar(50);
	SELECT @DB = DB_NAME();

	INSERT INTO DBA.dbo.IndexBackup 
	SELECT 
	@CollectTime as [CollectTime], 
	@DB as [DB],
	Schema_name(T.Schema_id) as [SchemaName],
	T.name as [TableName],
	T.is_ms_shipped as [Is_ms_shipped],
	I.name as [IndexName],
	N'' CREATE '' + 
		CASE WHEN I.is_unique = 1 THEN N'' UNIQUE '' ELSE N'''' END  +  
		I.type_desc COLLATE DATABASE_DEFAULT + N'' INDEX '' +   
		I.name  + N'' ON ''  +  
		Schema_name(T.Schema_id)+N''.''+T.name + N'' ( '' + 
		KeyColumns + N'' )  '' + 
		ISNULL(N'' INCLUDE (''+IncludedColumns+N'' ) '','''') + 
		ISNULL(N'' WHERE  ''+I.Filter_definition,N'''') + N'' WITH ( '' + 
		CASE WHEN I.is_padded = 1 THEN N'' PAD_INDEX = ON '' ELSE N'' PAD_INDEX = OFF '' END + N'',''  + 
		N''FILLFACTOR = ''+CONVERT(CHAR(5),CASE WHEN I.Fill_factor = 0 THEN 100 ELSE I.Fill_factor END) + N'',''  + 
		N''SORT_IN_TEMPDB = OFF ''  + N'',''  + 
		CASE WHEN I.ignore_dup_key = 1 THEN N'' IGNORE_DUP_KEY = ON '' ELSE N'' IGNORE_DUP_KEY = OFF '' END + N'',''  + 
		CASE WHEN ST.no_recompute = 0 THEN N'' STATISTICS_NORECOMPUTE = OFF '' ELSE N'' STATISTICS_NORECOMPUTE = ON '' END + N'',''  + 
		N'' DROP_EXISTING = ON ''  + N'',''  + 
		N'' ONLINE = OFF ''  + N'',''  + 
	   CASE WHEN I.allow_row_locks = 1 THEN N'' ALLOW_ROW_LOCKS = ON '' ELSE N'' ALLOW_ROW_LOCKS = OFF '' END + N'',''  + 
	   CASE WHEN I.allow_page_locks = 1 THEN N'' ALLOW_PAGE_LOCKS = ON '' ELSE N'' ALLOW_PAGE_LOCKS = OFF '' END  + N'' ) ON ['' + 
	   DS.name + N'' ] ''  as [CreateIndexSql]
	FROM sys.indexes I   
	 JOIN sys.tables T ON T.Object_id = I.Object_id    
	 JOIN sys.sysindexes SI ON I.Object_id = SI.id AND I.index_id = SI.indid   
	 JOIN (SELECT * FROM (  
		SELECT IC2.object_id , IC2.index_id ,  
			STUFF((SELECT N'' , '' + C.name + CASE WHEN MAX(CONVERT(INT,IC1.is_descending_key)) = 1 THEN N'' DESC '' ELSE N'' ASC '' END 
		FROM sys.index_columns IC1  
		JOIN Sys.columns C   
		   ON C.object_id = IC1.object_id   
		   AND C.column_id = IC1.column_id   
		   AND IC1.is_included_column = 0  
		WHERE IC1.object_id = IC2.object_id   
		   AND IC1.index_id = IC2.index_id   
		GROUP BY IC1.object_id,C.name,index_id  
		ORDER BY MAX(IC1.key_ordinal)  
		   FOR XML PATH(N'''')), 1, 2, N'''') KeyColumns   
		FROM sys.index_columns IC2   
		GROUP BY IC2.object_id ,IC2.index_id) tmp3 ) tmp4   
	  ON I.object_id = tmp4.object_id AND I.Index_id = tmp4.index_id  
	 JOIN sys.stats ST ON ST.object_id = I.object_id AND ST.stats_id = I.index_id   
	 JOIN sys.data_spaces DS ON I.data_space_id=DS.data_space_id   
	 Left JOIN sys.filegroups FG ON I.data_space_id=FG.data_space_id   
	 Left JOIN sys.partition_schemes Ps ON I.data_space_id=Ps.data_space_id 
	 LEFT JOIN (SELECT * FROM (   
		SELECT IC2.object_id , IC2.index_id ,   
			STUFF((SELECT N'' , '' + C.name  
		FROM sys.index_columns IC1   
		JOIN Sys.columns C    
		   ON C.object_id = IC1.object_id    
		   AND C.column_id = IC1.column_id    
		   AND IC1.is_included_column = 1   
		WHERE IC1.object_id = IC2.object_id    
		   AND IC1.index_id = IC2.index_id    
		GROUP BY IC1.object_id,C.name,index_id   
		   FOR XML PATH(N'''')), 1, 2, N'''') IncludedColumns    
	   FROM sys.index_columns IC2       
	   GROUP BY IC2.object_id ,IC2.index_id) tmp1   
	   WHERE IncludedColumns IS NOT NULL ) tmp2    
	ON tmp2.object_id = I.object_id AND tmp2.index_id = I.index_id   
	WHERE I.is_primary_key = 0 AND I.is_unique_constraint = 0 ;
	PRINT @@ROWCOUNT;
	'
	EXEC(@sqlcmd)
	
    SET @RowID = @RowID + 1;
END

DROP TABLE #DB;

PRINT N'DELETE HISTORY';
delete  DBA.dbo.IndexBackup WHERE CollectDateTime < CAST(DATEADD(DAY, -30, GETDATE()) AS DATE);
PRINT @@ROWCOUNT;

GO








