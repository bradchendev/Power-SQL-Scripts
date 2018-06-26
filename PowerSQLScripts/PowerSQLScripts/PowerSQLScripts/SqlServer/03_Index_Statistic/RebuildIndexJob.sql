-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/6/25
-- Description:	Rebuld Index Store procedure and Execute Rebuild History Table
-- 
-- =============================================


USE [DBA]
GO

/****** Object:  Table [dbo].[IndexRebuildHistory]    Script Date: 06/25/2018 11:23:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IndexRebuildHistory](
	[Sn] [int] IDENTITY(1,1) NOT NULL,
	[StartTime] [datetime] NULL,
	[FinishTime] [datetime] NULL,
	[DB] [nvarchar](50) NULL,
	[SchemaName] [nvarchar](50) NULL,
	[TableName] [nvarchar](200) NULL,
	[Is_ms_shipped] [bit] NULL,
	[IndexName] [nvarchar](500) NULL,
	[RebuildReason] [nvarchar](80) NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[ExecRebuildIndexSql] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Sn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO





-- CREATE BY Brad Chen
-- USE [muchnewdb]
-- EXEC DBA.dbo.uspRebuildIndex @DB =N'muchnewdb' ,@RebuidOnline = 0;
-- EXEC DBA.dbo.uspRebuildIndex @DB =N'muchnewdb' ,@RebuidOnline = 1;
-- EXEC DBA.dbo.uspRebuildIndex @DB =N'ABCJR' ,@RebuidOnline = 1;
ALTER PROCEDURE dbo.uspRebuildIndex
@DB sysname, @RebuidOnline bit = 0
AS
SET NOCOUNT ON;  

DECLARE @SQL nvarchar(1000);

DECLARE @fragReorgThreshold float = 10.0;
DECLARE @fragRebuildThreshold float = 30.0;

IF EXISTS(SELECT * from tempdb.sys.tables where name = '##TmpRebuildIndexList')
	DROP TABLE ##TmpRebuildIndexList

SET @SQL = N'
USE [' + @DB + N']; 
SELECT  
	IDENTITY(INT,1,1) AS [sn],
    o.name as [objectname], 
    s.name as [schemaname],
    o.is_ms_shipped,
    idx.name as [indexname],
    idx.fill_factor as [fillfactor],
    idxPs.partition_number AS [partitionnum],  
    idxPs.avg_fragmentation_in_percent AS [frag],
    (SELECT count (*)  
        FROM sys.partitions as p 
        WHERE p.[object_id] = idxPs.[object_id] AND p.[index_id] = idxPs.index_id ) as [partitioncount] 
INTO ##TmpRebuildIndexList 
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, ''LIMITED'')  as idxPs
INNER JOIN sys.objects AS o ON o.[object_id] = idxPs.[object_id]
INNER JOIN sys.schemas as s ON s.[schema_id] = o.[schema_id]  
INNER JOIN sys.indexes as idx ON idxPs.[object_id] = idx.[object_id] and idxPs.[index_id] = idx.index_id
WHERE idxPs.avg_fragmentation_in_percent >  ' + CAST(@fragReorgThreshold as nvarchar) + N' AND idxPs.index_id > 0 AND idxPs.page_count > 1000;'
--PRINT @SQL

EXEC(@SQL);

DECLARE @partitionnum bigint;  
DECLARE @frag float;  

DECLARE @objectname nvarchar(130);   
DECLARE @schemaname nvarchar(130);   
DECLARE @is_ms_shipped bit;   
DECLARE @indexname nvarchar(130);  
DECLARE @fillFactor tinyint; 

DECLARE @partitioncount bigint;  
DECLARE @command nvarchar(500);

DECLARE @RebuildReason nvarchar(80);
DECLARE @WithCmd nvarchar(200);

DECLARE @Sn table (Sn int);


Declare @count int, @i int
SET @i = 1
SELECT @count=count(*) FROM ##TmpRebuildIndexList

While @i <= @count
Begin	
	SELECT 
		@objectname = QUOTENAME([objectname]),
		@schemaname = QUOTENAME([schemaname]),
		@is_ms_shipped = [is_ms_shipped],
		@indexname = [indexname],
		@fillFactor = [fillfactor],
		@partitionnum = [partitionnum], 
		@frag = [frag],
		@partitioncount = [partitioncount]
	FROM ##TmpRebuildIndexList 
	WHERE Sn = @i;

	SET @RebuildReason = N'';
	SET @WithCmd = N'';
	
	-- Reorganizing
    IF @frag < @fragRebuildThreshold  
		BEGIN
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';  
        SET @RebuildReason = N'Fragment Threshold Between ' + CAST(@fragReorgThreshold as nvarchar) + N' and ' + CAST(@fragRebuildThreshold as nvarchar)
        -- Reorganizing an index is always executed online. 
        IF @partitioncount > 1  
			SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));  
        END
    -- REBUILD
    IF @frag >= @fragRebuildThreshold  
		BEGIN
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';  
        IF @partitioncount > 1  
			SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));              
		IF @fillFactor = 0
			SET @WithCmd = N' FILLFACTOR = 100'
		ELSE  
			SET @WithCmd = N' FILLFACTOR = ' + CAST(@fillFactor as nvarchar(3))
			
        IF @RebuidOnline = 1  
			SET @WithCmd = @WithCmd + N' , ONLINE = ON';
            
		SET @command = @command + N' WITH ' + QUOTENAME(@WithCmd,'()')
        SET @RebuildReason = N'Above or equal Fragment Rebuild Threshold ' + CAST(@fragRebuildThreshold as nvarchar)
		END
        INSERT INTO DBA.dbo.IndexRebuildHistory
        (
			[StartTime],
			[DB],
			[SchemaName],
			[TableName],
			[Is_ms_shipped],
			[IndexName],
			[RebuildReason],
			[avg_fragmentation_in_percent],
			[ExecRebuildIndexSql]
		) 
		OUTPUT inserted.Sn INTO @Sn 
		VALUES(GETDATE(),@DB,PARSENAME(@schemaname,1),PARSENAME(@objectname,1),@is_ms_shipped,PARSENAME(@indexname,1),@RebuildReason,@frag,@command);
         
        
		BEGIN TRY
			EXEC(@command); 
			UPDATE DBA.dbo.IndexRebuildHistory
			SET [FinishTime] = GETDATE() 
			WHERE Sn = (SELECT TOP(1) Sn FROM @Sn);
			DELETE @Sn; 
        END TRY
		BEGIN CATCH
			DELETE @Sn; 
		END CATCH
		
		
	set @i = @i + 1		
End

IF EXISTS(SELECT * from tempdb.sys.tables where name = '##TmpRebuildIndexList')
	DROP TABLE ##TmpRebuildIndexList


GO  

