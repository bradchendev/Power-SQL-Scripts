  -- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Transaction Log DBCC

-- =============================================



-- DBCC SQLPERF(LOGSPACE) 


DBCC LOGINFO
--or

DBCC LOGINFO(N'AdventureWorsk2008R2');
GO


-- Status
-- Status = 0 : not in use
 --Status =2 : in use

-- FSeqNo: This is the virtual log sequence number and the latest is the last log


-- after backup log, then status change from 2 to 0
