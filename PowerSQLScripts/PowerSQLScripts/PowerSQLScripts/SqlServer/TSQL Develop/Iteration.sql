-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/4/13
-- Description:	Iteration 
-- WHLE Loop

-- =============================================

USE AdventureWorks2008R2;  
GO  

declare @i int;
SET @i = 0;

WHILE @i <= 10  
BEGIN  
	
	PRINT @i;
	SET @i = @i + 1;

   --UPDATE Production.Product  
   --   SET ListPrice = ListPrice * 2  
   --SELECT MAX(ListPrice) FROM Production.Product  
   --IF (SELECT MAX(ListPrice) FROM Production.Product) > $500  
   --   BREAK  
   --ELSE  
   --   CONTINUE  
      
END  
PRINT 'Finish!!!';
