-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/12
-- Description:	SQLTrace Collection Step 4

-- =============================================


-- [CopyBackupFilesFromSQLServer01.bat]
-- Create batch in RML ReadTrace Server

--robocopy \\SQLServer01\i$\DBA\SQLTraceFiles D:\SQLTraceFiles *.* /S /copy:DAT /maxage:14 /xo /xf *.dll /MT:1 /R:10 /W:60 /fp /ts /np /log:D:\SQLTraceFiles\_CopyBackupFilesFromSQLServer01.log
--if errorlevel geq 8 exit /b 1
--exit /b 0

