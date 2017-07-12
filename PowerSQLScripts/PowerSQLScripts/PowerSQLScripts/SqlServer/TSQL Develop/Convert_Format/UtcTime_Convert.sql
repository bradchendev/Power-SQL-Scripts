-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/12
-- Description:	UtcTime Convert
-- CAST and CONVERT (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
-- datetime (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/datetime-transact-sql
-- Date and Time Data Types and Functions (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql
-- =============================================


DROP TABLE dbo.Table_2

CREATE TABLE dbo.Table_2
(
[OrderId] int primary key IDENTITY(1,1),
[OrderUtcDateTime] datetime
)


BEGIN
INSERT INTO dbo.Table_2(OrderUtcDateTime) VALUES(GETUTCDATE());
WAITFOR DELAY '00:00:05';
INSERT INTO dbo.Table_2(OrderUtcDateTime) VALUES(GETUTCDATE());
WAITFOR DELAY '00:00:05';
INSERT INTO dbo.Table_2(OrderUtcDateTime) VALUES(GETUTCDATE());
END

SELECT   
[OrderUtcDateTime] as [UTC DatetimeColumn]
,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [OrderUtcDateTime])  as [Local Datetime]
  FROM  dbo.Table_2

