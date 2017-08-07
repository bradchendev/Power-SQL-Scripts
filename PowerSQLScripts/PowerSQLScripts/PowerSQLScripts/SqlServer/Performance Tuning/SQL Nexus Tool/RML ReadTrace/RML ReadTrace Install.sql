-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/8/3
-- Description:	  RML Utilities 
--[安裝軟體與安裝方法]
--RML Utilities (ReadTrace)
--https://sqlnexus.codeplex.com/wikipage?title=ReadTrace&referringTitle=Installation
-- =============================================


--RML Utilities (ReadTrace)

--Please refer this KB for detals on downloading ReadTrace
--RML Utilities for SQL Server (x86) – http://www.microsoft.com/downloads/details.aspx?FamilyId=7EDFA95A-A32F-440F-A3A8-5160C8DBE926&displaylang=en
--RML Utilities for SQL Server (x64) – http://www.microsoft.com/downloads/details.aspx?FamilyId=B60CDFA3-732E-4347-9C06-2D1F1F84C342&displaylang=en
--Last edited Mar 7, 2014 at 2:24 AM by jackli, version 3

--comments

--shbarr Apr 27, 2012 at 12:13 AM 
--RML Utilities requires Report Viewer 2008 SP1 to run correctly and Report Viewer also has a few updates to be considered. 

--So from what I can tell the installation steps would be as follows: 
--1. Install Microsoft Report View 2008 SP1 or 2010 
--->Microsoft Report Viewer 2008 SP1 Redistributable - http://www.microsoft.com/download/en/details.aspx?id=3841 
--->Microsoft Report Viewer 2010 SP1 Redistributable Package - http://www.microsoft.com/download/en/details.aspx?id=6610

--2. Install relevant updates for Report Viewer: 
---> 2008 - Security Update MS09-062 - http://support.microsoft.com/kb/971119 
---> 2010 – Hotfixes - http://support.microsoft.com/kb/2549864

--3. Install RML Utilities - http://support.microsoft.com/kb/944837 

--4. Install SQL Nexus