-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Current Login User

-- =============================================

SELECT CURRENT_USER, SYSTEM_USER;

SELECT IS_SRVROLEMEMBER('sysadmin', 'TUTORABC\bradchen')


-- linked to another sql server mapping user
--SELECT * FROM OPENQUERY([SQL2008R2S1], 'SELECT CURRENT_USER, SYSTEM_USER');



-- 本地登入帳戶
SELECT CURRENT_USER, SYSTEM_USER;

-- 若透過Linked Server登入遠端的帳戶
SELECT * FROM OPENQUERY([SQL2008R2S1], 'SELECT CURRENT_USER, SYSTEM_USER');

