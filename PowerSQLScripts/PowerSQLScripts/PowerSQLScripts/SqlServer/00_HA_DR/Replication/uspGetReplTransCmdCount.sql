-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/06/21
-- Description:	Get replicated command count from distribution DB

-- Transactional Replication Conversations
-- https://blogs.msdn.microsoft.com/repltalk/2010/02/21/transactional-replication-conversations/
-- =============================================

USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[uspGetReplTransCmdCount]    Script Date: 06/21/2018 18:22:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- V3 
-- Create Date: 2018-06-21
-- Create By: Brad Chen
--
-- EXEC uspGetReplTransCmdCount @MinuteLev = 0
-- EXEC uspGetReplTransCmdCount @MinuteLev = 1
-- 
ALTER PROCEDURE [dbo].[uspGetReplTransCmdCount]
@MinuteLev bit = 0
AS

DECLARE @SQLDropTable nvarchar(250)
DECLARE @SQL1 nvarchar(1900)
DECLARE @SQL2 nvarchar(550)
DECLARE @SQL3 nvarchar(650)
DECLARE @SQL4 nvarchar(650)
DECLARE @MiniteSelect nvarchar(40) = N'';
DECLARE @MiniteGroupBy nvarchar(30) = N'';
DECLARE @MiniteOrderBy nvarchar(30) = N';';

IF @MinuteLev = 1
	BEGIN
	SET @MiniteSelect = N',datepart(mi, EntryTime) as Minute ';
	SET @MiniteGroupBy = N',datepart(mi, EntryTime) ';
	SET @MiniteOrderBy = N',Minute ';	
	END


SET @SQLDropTable = N'IF EXISTS(SELECT * from tempdb.sys.tables where name = ''##ReplTranCmds'')
	DROP TABLE ##ReplTranCmds;
IF EXISTS(SELECT * from tempdb.sys.tables where name = ''##ReplTranCmds2'')
	DROP TABLE ##ReplTranCmds2;';

SET @SQL1 = N'
USE [distribution];
SELECT 
atcl.publisher_db,
t.xact_seqno,
atcl.publication,
max(t.entry_time) as EntryTime, 
count(c.xact_seqno) as CommandCount 
INTO ##ReplTranCmds
FROM MSrepl_commands c with (nolock)
LEFT JOIN  msrepl_transactions t with (nolock)
      on t.publisher_database_id = c.publisher_database_id
      and t.xact_seqno = c.xact_seqno
LEFT JOIN 
( select 
db.id as [publisher_database_id],
pub.publication,
a.article,
a.article_id,
a.publisher_db
from 
 MSarticles as a with (nolock)
 INNER JOIN MSpublisher_databases as db with (nolock)
 ON a.publisher_id = db.publisher_id and a.publisher_db = db.publisher_db
 INNER JOIN MSpublications as pub with (nolock)
 ON a.publication_id = pub.publication_id
) atcl
on c.publisher_database_id = atcl.publisher_database_id and c.article_id = atcl.article_id
GROUP BY atcl.publisher_db, t.xact_seqno, atcl.publication;

SELECT 
atcl.publisher_db,
t.xact_seqno,
atcl.publication,
atcl.article,
max(t.entry_time) as EntryTime, 
count(c.xact_seqno) as CommandCount 
INTO ##ReplTranCmds2
FROM MSrepl_commands c with (nolock)
LEFT JOIN  msrepl_transactions t with (nolock)
      on t.publisher_database_id = c.publisher_database_id
      and t.xact_seqno = c.xact_seqno
LEFT JOIN 
( select 
db.id as [publisher_database_id],
pub.publication,
a.article,
a.article_id,
a.publisher_db
from 
 MSarticles as a with (nolock)
 INNER JOIN MSpublisher_databases as db with (nolock)
 ON a.publisher_id = db.publisher_id and a.publisher_db = db.publisher_db
 INNER JOIN MSpublications as pub with (nolock)
 ON a.publication_id = pub.publication_id
) atcl
on c.publisher_database_id = atcl.publisher_database_id and c.article_id = atcl.article_id
GROUP BY atcl.publisher_db, t.xact_seqno, atcl.publication, atcl.article;


'

SET @SQL2 = N'
USE [distribution];
SELECT publisher_db
      ,datepart(year, EntryTime) as Year
      ,datepart(month, EntryTime) as Month
      ,datepart(day, EntryTime) as Day
      ,datepart(hh, EntryTime) as Hour'
      + @MiniteSelect +
      N',sum(CommandCount) as CommandCountPerTimeUnit
FROM ##ReplTranCmds 
GROUP BY publisher_db
      ,datepart(year, EntryTime)
      ,datepart(month, EntryTime)
      ,datepart(day, EntryTime)
      ,datepart(hh, EntryTime)'
      + @MiniteGroupBy +
N'ORDER BY publisher_db,Year, Month, Day, Hour'+ @MiniteOrderBy


SET @SQL3 = N'
USE [distribution];
SELECT publisher_db
	,publication
      ,datepart(year, EntryTime) as Year
      ,datepart(month, EntryTime) as Month
      ,datepart(day, EntryTime) as Day
      ,datepart(hh, EntryTime) as Hour '
      + @MiniteSelect +
      N',sum(CommandCount) as CommandCountPerTimeUnit
FROM ##ReplTranCmds 
GROUP BY publisher_db
	,publication
      ,datepart(year, EntryTime)
      ,datepart(month, EntryTime)
      ,datepart(day, EntryTime)
      ,datepart(hh, EntryTime)'
      + @MiniteGroupBy + 
N'ORDER BY publisher_db,publication, Year, Month, Day, Hour'+ @MiniteOrderBy

SET @SQL4 = N'
USE [distribution];
SELECT publisher_db
	,publication
	,article
      ,datepart(year, EntryTime) as Year
      ,datepart(month, EntryTime) as Month
      ,datepart(day, EntryTime) as Day
      ,datepart(hh, EntryTime) as Hour '
      + @MiniteSelect +
      N',sum(CommandCount) as CommandCountPerTimeUnit
FROM ##ReplTranCmds2  
GROUP BY publisher_db
	,publication
	,article
      ,datepart(year, EntryTime)
      ,datepart(month, EntryTime)
      ,datepart(day, EntryTime)
      ,datepart(hh, EntryTime)'
      + @MiniteGroupBy + 
N'ORDER BY publisher_db,publication, article, Year, Month, Day, Hour'+ @MiniteOrderBy


--PRINT @SQLDropTable
--PRINT @SQL1
--PRINT @SQL2
--PRINT @SQL3
--PRINT @SQL4

EXEC(@SQLDropTable)
EXEC(@SQL1)
EXEC(@SQL2)
EXEC(@SQL3)
EXEC(@SQL4)
EXEC(@SQLDropTable)


