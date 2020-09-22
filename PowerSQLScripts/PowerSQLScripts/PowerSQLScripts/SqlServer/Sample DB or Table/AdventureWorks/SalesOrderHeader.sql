
SELECT TOP (1000) 
		SOH.[SalesOrderID]
      ,SOH.[OrderDate]
      ,SOH.[DueDate]
      --,SOH.[Status]
	  ,CASE SOH.[Status] 
		WHEN 1 THEN 'In process'
		WHEN 2 THEN 'Approved'
		WHEN 3 THEN 'Backordered'
		WHEN 4 THEN 'Rejected'
		WHEN 5 THEN 'Shipped'
		WHEN 6 THEN 'Cancelled'
	  END as [Status]
      --,SOH.[SalesOrderNumber]
      --,SOH.[PurchaseOrderNumber]
      --,SOH.[AccountNumber]
	  ,CxP.FirstName as [CustomerFName]
	  ,CxP.LastName as [CustomerLName]
      --,SOH.[CustomerID]
	  ,P.FirstName as [SalesFName]
	  ,P.LastName as [SalesLName]
      --,SOH.[SalesPersonID]
	  ,ST.Name as [Territory]
      --,SOH.[TerritoryID]
      --,SOH.[CurrencyRateID]
      ,SOH.[SubTotal]
      ,SOH.[TaxAmt]
      ,SOH.[Freight]
      ,SOH.[TotalDue]
  FROM [AdventureWorks2017].[Sales].[SalesOrderHeader] SOH
  INNER JOIN [Sales].[SalesPerson] SP on SOH.SalesPersonID = SP.BusinessEntityID
  INNER JOIN [Person].[Person] P on  SP.BusinessEntityID = P.BusinessEntityID
  INNER JOIN [Sales].[SalesTerritory] ST on SOH.TerritoryID = ST.TerritoryID
  INNER JOIN [Sales].[Customer] Cx on SOH.CustomerID = Cx.CustomerID
  INNER JOIN [Person].[Person] CxP on Cx.PersonID = CxP.BusinessEntityID

