-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/4/13
-- Description:	Disk Free space and check if a file or folder exist
-- =============================================


EXEC master..xp_fixeddrives

--drive	MB free
--C	152439
--D	48846
--E	383907



EXEC master..xp_fileexist 'C:\Windows\notepad.exe'
--File Exists	File is a Directory	Parent Directory Exists
--0	0	1

EXEC master..xp_fileexist 'C:\Windows\System32\notepad.exe'
--File Exists	File is a Directory	Parent Directory Exists
--1	0	1

EXEC master..xp_fileexist 'C:\Windows\System32'
--File Exists	File is a Directory	Parent Directory Exists
--0	1	1
