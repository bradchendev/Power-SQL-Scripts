USE AdventureWorks2008R2
GO
-- =============================================
-- Author:        Brad Chen
-- Create date:    <建立日期,Date,>
-- Description:    <說明,字串,>
-- Modified By    Modification Date    Modification Description
--          
-- =============================================

CREATE PROCEDURE dbo.uspGetOrders
(
@Param1 BIT = 0 -- 0:False; 1:True
,@Param2 VARCHAR(10) OUTPUT -- 回傳參數值
)
AS
BEGIN TRY 
	BEGIN
		SET NOCOUNT ON;   
		--程式邏輯寫在這
		SELECT *FROM dbo.AlvinTest
	END 
END TRY 
BEGIN CATCH
	EXEC dbo.uspRaiseError;
END CATCH
GO

GRANT EXEC ON dbo.uspGetOrders TO [AppUser1]
GO