-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/9/26
-- Description:	產生GRANT VIEW DEFINITION ON ALL PROCS權限
-- =============================================


SELECT 
'GRANT VIEW DEFINITION ON ' + quotename([name]) 
+ '.' + quotename([name])
+ ' TO ' + 'YourDbUserName'
  from sys.procedures
