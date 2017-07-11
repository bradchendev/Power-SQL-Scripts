-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	Dynamic Where Condition動態Where條件

-- Where使用 @variable is null or [Column] = @vaiable會導致Index無效

-- =============================================


USE [AdventureWorks2008R2]
GO
CREATE NONCLUSTERED INDEX [Idx_SalesOrderDetail_ProductId_ModifiedDate] ON [Sales].[SalesOrderDetail] 
(
	[ProductID] ASC,
	[ModifiedDate] ASC
)
INCLUDE ( [OrderQty],
[UnitPrice],
[UnitPriceDiscount])ON [PRIMARY]
GO



DECLARE @ProdId int = 778
DECLARE @ModifiedDate datetime = '2005-08-01'



-- Bad, Index Scan
SELECT 
	[OrderQty],[UnitPrice],[UnitPriceDiscount]
  FROM [Sales].[SalesOrderDetail]
  WHERE 
  1 = 1
  AND (@ProdId is null OR [ProductID] = @ProdId)
  AND (@ModifiedDate is null OR [ModifiedDate] < @ModifiedDate)

  
-- Good, Index Seek 
--SELECT 
--	[OrderQty],[UnitPrice],[UnitPriceDiscount]
--  FROM [Sales].[SalesOrderDetail]
--  WHERE [ProductID] = @ProdId
--  and [ModifiedDate] < @ModifiedDate

-- Solution
--1.If Else
--2.Dynamic SQL