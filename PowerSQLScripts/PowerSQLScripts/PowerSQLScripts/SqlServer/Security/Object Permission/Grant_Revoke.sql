-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Grant and Revoke 權限
-- GRANT Object Permissions (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms188371.aspx
-- REVOKE Object Permissions (Transact-SQ
-- https://msdn.microsoft.com/en-us/library/ms187719.aspx
-- =============================================


USE AdventureWorks2012;  
GRANT SELECT ON OBJECT::Person.Address TO RosaQdM;  
GO
-- equal
USE AdventureWorks2012;  
GRANT SELECT ON Person.Address TO RosaQdM;  
GO 

-- GRANT ON Column
USE AdventureWorks2012;  
GRANT SELECT ON Person.Address(PostalCode)  TO RosaQdM;  
GO 

USE AdventureWorks2012;  
GRANT SELECT ON Person.Address TO [AdventureWorks2012\RosaQdM];  
GO

USE AdventureWorks2012;  
CREATE ROLE newrole ;  
GRANT EXECUTE ON dbo.uspGetBillOfMaterials TO newrole ;  
GO 

USE AdventureWorks2012;  
GRANT REFERENCES (BusinessEntityID) ON OBJECT::HumanResources.vEmployee   
    TO Wanida WITH GRANT OPTION;  
GO  
