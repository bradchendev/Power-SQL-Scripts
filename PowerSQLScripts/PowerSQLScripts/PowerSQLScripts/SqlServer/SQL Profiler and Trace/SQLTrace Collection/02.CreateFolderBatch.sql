-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/12
-- Description:	SQLTrace Collection Step 2

-- =============================================

-- [CreateFolderMoveTrcFile.bat]

--@echo off
--REM Creat by Brad 2016-10/18
--for /f "delims=" %%a in ('wmic OS Get localdatetime  ^| find "."') do set dt=%%a
--set datestamp=%dt:~0,8%
--set timestamp=%dt:~8,6%
--set YYYY=%dt:~0,4%
--set MM=%dt:~4,2%
--set DD=%dt:~6,2%
--set HH=%dt:~8,2%
--set Min=%dt:~10,2%
--set Sec=%dt:~12,2%

--set stamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%
--REM echo stamp: "%stamp%"
--REM echo datestamp: "%datestamp%"
--REM echo timestamp: "%timestamp%"

--I:
--cd I:\Temp\DBA\SQLTraceFiles

--if exist I:\Temp\DBA\SQLTraceFiles\*.trc mkdir %stamp% 2> nul

--if exist I:\Temp\DBA\SQLTraceFiles\*.trc move I:\Temp\DBA\SQLTraceFiles\*.trc I:\Temp\DBA\SQLTraceFiles\%stamp% 2> nul
