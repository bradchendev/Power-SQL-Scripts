-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2018/04/23
-- Description:	tablediff 比對兩的表資料差異，並產生補資料的DML sql statement

--tablediff Utility
--https://docs.microsoft.com/en-us/sql/tools/tablediff-utility?view=sql-server-2017

--SQL Server tablediff command line utility
--https://www.mssqltips.com/sqlservertip/1073/sql-server-tablediff-command-line-utility/

-- =============================================

"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1 -sourcedatabase test -sourcetable table1 -destinationserver server1 -destinationdatabase test -destinationtable table2
"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1  -destinationdatabase test -destinationtable table2 -et Difference
"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1 -destinationdatabase test -destinationtable table2 -et Difference -f c:\table1_differences.sql



1.
"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1 -sourcedatabase test -sourcetable table1 -destinationserver server1 -destinationdatabase test -destinationtable table2

-- sample 1
Microsoft (R) SQL Server Replication Diff Tool
Copyright (C) 1988-2005 Microsoft Corporation. All rights reserved.

User-specified agent parameter values:
-sourceserver server1
-sourcedatabase test
-sourcetable table1
-destinationserver server2
-destinationdatabase test
-destinationtable table2

Table [test].[dbo].[table1] on server1 and Table [test].[dbo].[table2] on server1 have 3 differences.
Err PersonID
Mismatch 1
Dest. Only 2
Src. Only 3
The requested operation took 0.4375 seconds.

-- sample 2
-- 如果比對資料不一致
C:\Windows\system32>"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe " -sourceserver SQL1 -sourcedatabase MyDB1 -sourcetable MyTable1 -destinationserver SQL2 -destinationdatabase MyDB1 -destinationtable MyTable1
Microsoft (R) SQL Server Replication Diff Tool
Copyright (c) 2008 Microsoft Corporation

User-specified agent parameter values:
-sourceserver SQL1
-sourcedatabase MyDB1
-sourcetable MyTable1
-destinationserver SQL2
-destinationdatabase MyDB1
-destinationtable MyTable1

Table [MyDB1].[dbo].[MyTable1] on SQL1 and Table [MyDB1].[dbo].[MyTable1] on SQL2 have 2 differences.
Err     id
Mismatch        366437
Mismatch        366733
The requested operation took 0.3783631 seconds.

-- 如果比對資料一致
C:\Windows\system32>"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe " -sourceserver SQL1 -sourcedatabase MyDB1 -sourcetable MyTable1 -destinationserver SQL2 -destinationdatabase MyDB1 -destinationtable MyTable1
Microsoft (R) SQL Server Replication Diff Tool
Copyright (c) 2008 Microsoft Corporation

User-specified agent parameter values:
-sourceserver SQL1
-sourcedatabase MyDB1
-sourcetable MyTable1
-destinationserver SQL2
-destinationdatabase MyDB1
-destinationtable MyTable1

Table [MyDB1].[dbo].[MyTable1] on SQL1 and Table [MyDB1].[dbo].[MyTable1] on SQL2 are identical.
The requested operation took 0.3653508 seconds.



2.
"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1  -destinationdatabase test -destinationtable table2 -et Difference

PersonId	MSdifftool_ErrorCode	MSdifftool_ErrorDescription
1	0	Mismatch
2	1	Dest. Only
3	2	Src. Only
NULL	NULL	NULL



3.
"C:\Program Files\Microsoft SQL Server\100\COM\tablediff.exe" -sourceserver server1  -sourcedatabase test -sourcetable table1 -destinationserver server1 -destinationdatabase test -destinationtable table2 -et Difference -f c:\table1_differences.sql

This is the output we get from the file that is created "c:\table1_differences.sql"
-- Host: server1
-- Database: [test]
-- Table: [dbo].[table2]
UPDATE [dbo].[table2] SET [LastName]=NULL WHERE [PersonID] = 1
DELETE FROM [dbo].[table2] WHERE [PersonID] = 2
INSERT INTO [dbo].[table2] ([FirstName],[LastName],[PersonID]) VALUES ('Bob','Jones',3)