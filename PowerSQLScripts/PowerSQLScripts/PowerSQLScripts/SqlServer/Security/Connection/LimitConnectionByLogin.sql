-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/9/29
-- Description:	
-- Logon Triggers
-- https://docs.microsoft.com/en-us/sql/relational-databases/triggers/logon-triggers
-- =============================================



USE [DBA]
CREATE TABLE [dbo].[LogonConnLimit](
	[sn] [int] PRIMARY KEY,
	[login] [nvarchar](50) NULL,
	[ConnLimit] [int] NULL
	);

-- grant all login 
-- GRANT SELECT ON [DBA].[dbo].[LogonConnLimit] TO UserAppLogin


USE [master]
CREATE TRIGGER [connection_limit_trigger]
ON ALL SERVER  
FOR LOGON
AS
BEGIN

	DECLARE @login nvarchar(30) = CAST(ORIGINAL_LOGIN() as nvarchar);
	--PRINT 'debug: @login=' + @login;
	--DECLARE @IsOverLimit bit = 0;

	DECLARE @Limit int
	SELECT TOP(1) @Limit = [ConnLimit] FROM [DBA].[dbo].[LogonConnLimit]
	WHERE [login] = @login

	--declare @curCount int;
	--SELECT @curCount = COUNT(*) FROM sys.dm_exec_sessions
	--				WHERE is_user_process = 1 AND
	--					original_login_name = @login

	--PRINT 'debug: @login=' + CAST(@login as nvarchar);
	--PRINT 'debug: @Limit=' + CAST(@Limit as nvarchar);
	--PRINT 'debug: @curCount=' + CAST(@curCount as nvarchar);
	
	-- 此連線會被算進去，所以用大於
	IF (SELECT COUNT(*) FROM sys.dm_exec_sessions  
				WHERE is_user_process = 1 AND  
					original_login_name = @login) > @Limit  
		ROLLBACK;  
END

GO


-- ======================
-- Troubleshooting
-- ======================
-- Use DAC connection
-- sqlcmd -A
-- DISABLE TRIGGER connection_limit_trigger ON ALL SERVER;
-- or
-- DROP TRIGGER connection_limit_trigger ON ALL SERVER;
