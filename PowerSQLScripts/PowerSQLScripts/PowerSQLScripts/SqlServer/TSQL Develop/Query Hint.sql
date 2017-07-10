-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Query Hint

-- =============================================



--Table Hints (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms187373.aspx

--FROM t WITH (TABLOCK, INDEX(myindex))

--  | FORCESCAN
--  | FORCESEEK
--  | HOLDLOCK 
--  | NOLOCK 
--  | NOWAIT
--  | PAGLOCK 
--  | READCOMMITTED 
--  | READCOMMITTEDLOCK 
--  | READPAST 
--  | READUNCOMMITTED 
--  | REPEATABLEREAD 
--  | ROWLOCK 
--  | SERIALIZABLE 
--  | SNAPSHOT 
--  | SPATIAL_WINDOW_MAX_CELLS = integer
--  | TABLOCK 
--  | TABLOCKX 
--  | UPDLOCK 
--  | XLOCK 

--指定使用特定Index
SELECT * 
  FROM [HumanResources].[Department] WITH (INDEX([AK_Department_Name]))
WHERE [name] = 'Finance'

--指定使用特定Index與鎖定方式
SELECT * 
  FROM [HumanResources].[Department] WITH (TABLOCK, INDEX([AK_Department_Name]))
WHERE [name] = 'Finance'

SELECT * 
  FROM [HumanResources].[Department] WITH (NOLOCK)
WHERE [name] = 'Finance'


--A. Using the TABLOCK hint to specify a locking method
--The following example specifies that a shared lock is taken on the Production.Product table in the AdventureWorks2012 database 
--and is held until the end of the UPDATE statement.
UPDATE Production.Product
WITH (TABLOCK)
SET ListPrice = ListPrice * 1.10
WHERE ProductNumber LIKE 'BK-%';
GO

--B. Using the FORCESEEK hint to specify an index seek operation
--The following example uses the FORCESEEK hint without specifying an index to force the query optimizer 
--to perform an index seek operation on the Sales.SalesOrderDetail table in the AdventureWorks2012 database.
SELECT *
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d WITH (FORCESEEK)
    ON h.SalesOrderID = d.SalesOrderID 
WHERE h.TotalDue > 100
AND (d.OrderQty > 5 OR d.LineTotal < 1000.00);
GO
--The following example uses the FORCESEEK hint with an index to force the query optimizer 
--to perform an index seek operation on the specified index and index column.
SELECT h.SalesOrderID, h.TotalDue, d.OrderQty
FROM Sales.SalesOrderHeader AS h
    INNER JOIN Sales.SalesOrderDetail AS d 
    WITH (FORCESEEK (PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID (SalesOrderID))) 
    ON h.SalesOrderID = d.SalesOrderID 
WHERE h.TotalDue > 100
AND (d.OrderQty > 5 OR d.LineTotal < 1000.00); 
GO

--C. Using the FORCESCAN hint to specify an index scan operation
--The following example uses the FORCESCAN hint to force the query optimizer 
--to perform a scan operation on the Sales.SalesOrderDetail table in the AdventureWorks2012 database.
SELECT h.SalesOrderID, h.TotalDue, d.OrderQty
FROM Sales.SalesOrderHeader AS h
    INNER JOIN Sales.SalesOrderDetail AS d 
    WITH (FORCESCAN) 
    ON h.SalesOrderID = d.SalesOrderID 
WHERE h.TotalDue > 100
AND (d.OrderQty > 5 OR d.LineTotal < 1000.00);



--Query Hints (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms181714.aspx

--F. Using MAXDOP
--The following example uses the MAXDOP query hint. The example uses the AdventureWorks2012 database.
SELECT ProductID, OrderQty, SUM(LineTotal) AS Total  
FROM Sales.SalesOrderDetail  
WHERE UnitPrice < $5.00  
GROUP BY ProductID, OrderQty  
ORDER BY ProductID, OrderQty  
OPTION (MAXDOP 2);  



--A. Using MERGE JOIN
--The following example specifies that the JOIN operation in the query is performed by MERGE JOIN. The example uses the AdventureWorks2012 database.
SELECT *   
FROM Sales.Customer AS c  
INNER JOIN Sales.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID  
WHERE TerritoryID = 5  
OPTION (MERGE JOIN);  
GO  







--Join Hints (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms173815.aspx

--A. Using HASH
--The following example specifies that the JOIN operation in the query is performed by a HASH join. 
--The example uses the AdventureWorks2012 database.
SELECT p.Name, pr.ProductReviewID
FROM Production.Product AS p
LEFT OUTER HASH JOIN Production.ProductReview AS pr
ON p.ProductID = pr.ProductID
ORDER BY ProductReviewID DESC;


--B. Using LOOP
--The following example specifies that the JOIN operation in the query is performed by a LOOP join. 
--The example uses the AdventureWorks2012 database.
DELETE FROM Sales.SalesPersonQuotaHistory 
FROM Sales.SalesPersonQuotaHistory AS spqh
    INNER LOOP JOIN Sales.SalesPerson AS sp
    ON spqh.SalesPersonID = sp.SalesPersonID
WHERE sp.SalesYTD > 2500000.00;
GO
?
?
--C. Using MERGE
--The following example specifies that the JOIN operation in the query is performed by a MERGE join. 
--The example uses the AdventureWorks2012 database.
SELECT poh.PurchaseOrderID, poh.OrderDate, pod.ProductID, pod.DueDate, poh.VendorID 
FROM Purchasing.PurchaseOrderHeader AS poh
INNER MERGE JOIN Purchasing.PurchaseOrderDetail AS pod 
    ON poh.PurchaseOrderID = pod.PurchaseOrderID;

GO
