-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	DB_Transaction_in_Datafile

-- =============================================

dbcc shrinkfile(MyDB2_D3, EMPTYFILE)

ALTER DATABASE MyDB2  
REMOVE FILE MyDB2_D3;  
GO  

-- 如果有交易進行中，則dbcc shrinkfile(MyDB2_D3, EMPTYFILE)會被Blocking
SELECT 
tdt.database_id,
Case database_transaction_state When  1 then '交易未初始化'
When  3 then '交易已初始化，但未產生任何記錄'
When  4 then '交易已產生記錄'
When 5 then '已準備交易'
When  10 then '已認可交易'
When  11 then '已回復交易'
When  12 then '正在認可交易' end as [DB_Tran_State],
	
	tdt.database_transaction_log_bytes_reserved,tst.session_id,
    t.[text], [statement] = COALESCE(NULLIF(
         SUBSTRING(
           t.[text],
           r.statement_start_offset / 2,
           CASE WHEN r.statement_end_offset < r.statement_start_offset
             THEN 0
             ELSE( r.statement_end_offset - r.statement_start_offset ) / 2 END
         ), ''
       ), t.[text])
     FROM sys.dm_tran_database_transactions AS tdt
     INNER JOIN sys.dm_tran_session_transactions AS tst
     ON tdt.transaction_id = tst.transaction_id
         LEFT OUTER JOIN sys.dm_exec_requests AS r
         ON tst.session_id = r.session_id
         OUTER APPLY sys.dm_exec_sql_text(r.plan_handle) AS t
