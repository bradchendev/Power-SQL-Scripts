-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Modify date: 2017/8/3
-- Description:	  RML Utilities 
-- Cumulative Update 1 to the RML Utilities for Microsoft SQL Server Released
-- https://blogs.msdn.microsoft.com/psssql/2008/11/12/cumulative-update-1-to-the-rml-utilities-for-microsoft-sql-server-released/
-- =============================================

-- 未完全確認此語法的準確性，只透過TABLE的欄位名稱判斷組出此SQL語法
SELECT 
     (select OrigText from ReadTrace.tblUniqueBatches where hashId = a.hashId)
     ,(select NormText from ReadTrace.tblUniqueBatches where hashId = a.hashId)   
      ,SUM(CPU) as [CPU]
		,COUNT(*) as [count]
  FROM [ReadTraceDB20161116202501].[ReadTrace].[tblBatches] a
	inner join [ReadTrace].[tblUniqueBatches] b
	on a.HashID = b.HashID
  where (
		a.startTime > '2016-11-16 20:29:50.000'
		and
		a.startTime < '2016-11-16 20:32:00.000'
		)	
	GROUP BY a.HashID
	having SUM(CPU) > 20000
	order by SUM(CPU) DESC
	
-- 搜尋關鍵字 
-- Unique Batch 找出完整SQL語法 含參數
SELECT TOP 50
		--[BatchSeq]
  --    ,[HashID]
      [Session]
      --,[Request]
      --,[ConnId]
      ,[StartTime]
      ,[EndTime]
      ,[Duration]
      ,[Reads]
      ,[Writes]
      ,[CPU]
      --,[fRPCEvent]
      ,[DBID]
      --,[StartSeq]
      --,[EndSeq]
      --,[AttnSeq]
      --,[ConnSeq]
      ,[TextData]
      ,[OrigRowCount]
  FROM [ReadTraceDB20170802HR].[ReadTrace].[tblBatches]
  where TextData Like '%USP_RETURN_V_TERMINAL_LEAVE_FLOW%'
  order by CPU DESC
GO




-- 搜尋關鍵字 
-- Unique Statement 關聯到哪一個Unique Batch
-- 未完全確認此語法的準確性，只透過TABLE的欄位名稱判斷組出此SQL語法

SELECT TOP 10
[StmtSeq]
      --,[HashID]
      --,[Session]
      ,a.[Request]
      ,a.[ConnId]
      ,a.[StartTime]
      ,a.[EndTime]
      ,a.[Duration]
      ,a.[Reads]
      ,a.[Writes]
      ,a.[CPU]
      ,a.[Rows]
      ,a.[DBID]
      ,a.[ObjectID]
      ,a.[NestLevel]
      ,a.[fDynamicSQL]
      ,a.[StartSeq]
      ,a.[EndSeq]
      ,a.[ConnSeq]
      ,a.[BatchSeq]
      ,a.[ParentStmtSeq]
      ,a.[AttnSeq]
      ,a.[TextData]
      ,b.OrigText
      ,c.TextData
  FROM [ReadTraceDB20170802HR].[ReadTrace].[tblStatements] a
  LEFT join [ReadTraceDB20170802HR].ReadTrace.tblUniqueStatements b
  on a.[HashID] = b.[HashId]
  Left Join [ReadTraceDB20170802HR].ReadTrace.tblBatches c
  on c.BatchSeq = a.BatchSeq
  where b.[OrigText] like '%scheduled%'
  order by a.CPU DESC