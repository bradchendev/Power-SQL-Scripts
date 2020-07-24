-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2020/7/17
-- Description:	Recovery Mode to SIMPLE and delete rows in smaller batches using a while loop 

-- =============================================



-- Method 1
DECLARE @Deleted_Rows INT;
SET @Deleted_Rows = 1;
WHILE (@Deleted_Rows > 0)
  BEGIN
   -- Delete some small number of rows at a time
     DELETE TOP (10000)  LargeTable 
     WHERE readTime < dateadd(MONTH,-7,GETDATE())

  SET @Deleted_Rows = @@ROWCOUNT;
END



-- Method 2
SET NOCOUNT ON;
DECLARE @r INT;
SET @r = 1;
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION; 
  DELETE TOP (100000) -- this will change
    dbo.SalesOrderDetailEnlarged
    WHERE ProductID IN (712, 870, 873);
  SET @r = @@ROWCOUNT;
  COMMIT TRANSACTION;
  -- CHECKPOINT;    -- if simple
  -- BACKUP LOG ... -- if full
END