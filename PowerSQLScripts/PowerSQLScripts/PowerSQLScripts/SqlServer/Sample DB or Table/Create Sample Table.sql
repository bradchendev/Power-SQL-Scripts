-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Create Sample Table

-- =============================================


--建立測試用資料表
CREATE TABLE #SALES
    (
      CUSTOMER_ID INT NOT NULL ,
      ITEM_ID INT NOT NULL ,
      SALE_QUANTITY SMALLINT NOT NULL ,
      SALE_DATE DATE NOT NULL
    );
GO

INSERT INTO #SALES
SELECT RAND(CAST( NEWID() AS varbinary )) * 900 + 1 AS CUSTOMER_ID
    , RAND(CAST( NEWID() AS varbinary )) * 500 + 1 AS ITEM_ID
	, RAND(CAST( NEWID() AS varbinary )) * 10 + 1 AS SALE_QUANTITY
	, DATEADD(D, RAND(CAST( NEWID() AS varbinary )) * 100, '2000/1/1') AS  SALE_DATE
FROM sys.columns
go 5000

DROP TABLE #SALES