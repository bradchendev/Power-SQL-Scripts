
-- =============================================
-- Author:		Brad Chen
-- Create date: 2020-08-31
-- Description:	Clean DbFileSize table
-- @retentionPeriodDay default -60
-- =============================================
CREATE PROCEDURE [dbo].[uspCleanDbFileSize] 
	-- Add the parameters for the stored procedure here
	@retentionPeriodDay int = -180
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE [dbo].[DbFileSize]
	WHERE [ChkTime] < DATEADD(DAY,@retentionPeriodDay,GETDATE());
    -- Insert statements for procedure here
	SELECT @@ROWCOUNT; 
END
GO
