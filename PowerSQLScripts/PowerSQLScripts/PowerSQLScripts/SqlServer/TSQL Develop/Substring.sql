

-- 取得括弧裡面的值 
-- Select values inside parenthesis / select data between brackets 

create  TABLE Purchase_Audit  (serial bigint,  reason VARCHAR(50))
GO
-- Inserting Data into Table
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '1', 'Purchased Order 12345 (COXFFF6)')
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '2', 'Purchased Order 12555 (COXFFF1)')
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '3', 'Purchased Order 11115 (COXFFF2)')
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '4', 'Purchased Order 12005 (COXFFF4)')
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '5', 'Purchased Order 19875 (COXFFF5)')
INSERT INTO Purchase_Audit  (serial ,  reason)
VALUES ( '6', 'Purchased Order 16665 (COXFFF9)')
GO

Select
SUBSTRING(reason,CHARINDEX('(',reason)+1 ,CHARINDEX(')',reason)-CHARINDEX('(',reason)-1)  fromPurchase_Audit

