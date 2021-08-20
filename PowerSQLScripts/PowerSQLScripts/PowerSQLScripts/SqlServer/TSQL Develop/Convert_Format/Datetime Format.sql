-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Datetime and format 日期轉換與格式
-- CAST and CONVERT (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
-- datetime (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/datetime-transact-sql
-- Date and Time Data Types and Functions (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql
-- FORMAT (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/format-transact-sql
-- =============================================

-- 當天
SELECT CAST( GETDATE() AS DATE)
-- 2016-10-27

-- 前一天
SELECT CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)
-- 2016-10-26

-- 當月第一天
SELECT DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0) AS StartOfMonth
-- 2016-10-01 00:00:00.000
SELECT  CONVERT(nvarchar(10),DATEADD(month, DATEDIFF(month, 0, GETDATE() ), 0), 120)  AS StartOfMonth
-- 2016-10-01


-- current hour with 2-digital
select CAST(CAST(getdate() AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,getdate()) as varchar(2)),2) + ':00:00' as [d]
-- 2020-01-01 09:00:00

-- last hour with 2-digital
select CAST(CAST(getdate() AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,DATEADD(hour,-1,getdate())) as varchar(2)),2) + ':00:00' as [d]

-- current hour and minutes with 2-digital
select CAST(CAST(getdate() AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,getdate()) as varchar(2)),2) + ':' + right('0' + CAST(DATEPART(minute,getdate()) as varchar(2)),2) + ':00' as [d]
-- 2020-01-01 09:22:00



--declare @now datetime = cast('2020-01-01 00:22:00' as datetime)
--select DATEPART(HOUR,@now) 
declare @now datetime
--set @now = getdate();
set @now = cast('2020-07-15 23:22:00' as datetime)
DECLARE @startDate datetime 
DECLARE @endDate datetime
If DATEPART(HOUR,@now) = 0
BEGIN
	SET @startDate = CAST(CAST(DATEADD(day,-1,@now) AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,DATEADD(hour,-1,@now)) as varchar(2)),2) + ':00:00';
	SET @endDate = CAST(CAST(@now AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,@now) as varchar(2)),2) + ':00:00' ;
END
ELSE
BEGIN
    select 2;
	SET @startDate = CAST(CAST(@now AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,DATEADD(hour,-1,@now)) as varchar(2)),2) + ':00:00'
	SET @endDate = CAST(CAST(@now AS DATE) as varchar(10)) + ' ' + right('0' + CAST(DATEPART(hour,@now) as varchar(2)),2) + ':00:00' 
END
SELECT @startDate as [start], @endDate as [end]





--To get the first day of the previous month in SQL Server, use the following code:
SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) - 1, 0)
-- 2018-03-01 00:00:00.000

--To get the last day of the previous month:
SELECT DATEADD(DAY, -(DAY(GETDATE())), GETDATE())
-- 2018-03-31 11:55:06.467

--To get the first day of the current month:
SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)
--2018-04-01 00:00:00.000

--To get the last day of the current month:
SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))
--2018-04-30 00:00:00.000

--To get the first day of the next month:
SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)
-- 2018-05-01 00:00:00.000
--To get the last day of the next month:
SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 2, 0))
-- 2018-05-31 00:00:00.000





-- 只要日期 或 時間
SELECT
CONVERT(VARCHAR(8),GETDATE(),108) AS HourMinuteSecond,
CONVERT(VARCHAR(8),GETDATE(),101) AS DateOnly
GO
--HourMinuteSecond	DateOnly
--10:25:56	12/01/20


-- 將日期時間datetime 轉 nvarchar
select CONVERT(nvarchar(23), GETDATE(), 121)
-- 2016-12-01 10:21:23.087

select CONVERT(nvarchar(23), GETDATE(), 120)
-- 2016-12-01 10:21:23

select CONVERT(nvarchar(10), GETDATE(), 120)
-- 2016-12-01



declare @d datetime
set @d = '2014-04-17 13:55:12'
select replace(convert(varchar(8), @d, 112)+convert(varchar(8), @d, 114), ':','') 
-- 20140417135512

select replace(convert(varchar(8), GETDATE(), 112)+convert(varchar(8), GETDATE(), 114), ':','') 
-- 20161017142630



SELECT convert(varchar(8), GETDATE(), 112) -- yyyymmdd
SELECT convert(varchar(10), GETDATE(), 111) -- yyyy/mm/dd
SELECT convert(varchar(10), GETDATE(), 126) -- yyyy-mm-dd

SELECT convert(varchar(10), GETDATE(), 111) -- yyyy/mm/d
SELECT convert(varchar(10), GETDATE(), 101) -- mm/dd/yyyy
SELECT convert(varchar(10), GETDATE(), 103) -- dd/mm/yyyy
SELECT convert(varchar(10), GETDATE(), 105) -- dd-mm-yyyy



SELECT convert(datetime, '2016/10/23', 111) -- yyyy/mm/dd
SELECT convert(datetime, '20161023', 112) -- ISO yyyymmdd





-- DATETIME functions.

-- SQL Server string to date / datetime conversion - datetime string format sql server
-- MSSQL string to datetime conversion - convert char to date - convert varchar to date
-- Subtract 100 from style number (format) for yy instead yyyy (or ccyy with century)
SELECT convert(datetime, 'Oct 23 2012 11:01AM', 100) -- mon dd yyyy hh:mmAM (or PM)
SELECT convert(datetime, 'Oct 23 2012 11:01AM') -- 2012-10-23 11:01:00.000
 
-- Without century (yy) string date conversion - convert string to datetime function
SELECT convert(datetime, 'Oct 23 12 11:01AM', 0) -- mon dd yy hh:mmAM (or PM)
SELECT convert(datetime, 'Oct 23 12 11:01AM') -- 2012-10-23 11:01:00.000
 
-- Convert string to datetime sql - convert string to date sql - sql dates format
-- T-SQL convert string to datetime - SQL Server convert string to date
SELECT convert(datetime, '10/23/2016', 101) -- mm/dd/yyyy
SELECT convert(datetime, '2016.10.23', 102) -- yyyy.mm.dd ANSI date with century
SELECT convert(datetime, '23/10/2016', 103) -- dd/mm/yyyy
SELECT convert(datetime, '23.10.2016', 104) -- dd.mm.yyyy
SELECT convert(datetime, '23-10-2016', 105) -- dd-mm-yyyy
-- mon types are nondeterministic conversions, dependent on language setting
SELECT convert(datetime, '23 OCT 2016', 106) -- dd mon yyyy
SELECT convert(datetime, 'Oct 23, 2016', 107) -- mon dd, yyyy
-- 2016-10-23 00:00:00.000
SELECT convert(datetime, '20:10:44', 108) -- hh:mm:ss
-- 1900-01-01 20:10:44.000
 
-- mon dd yyyy hh:mm:ss:mmmAM (or PM) - sql time format - SQL Server datetime format
SELECT convert(datetime, 'Oct 23 2016 11:02:44:013AM', 109)
-- 2016-10-23 11:02:44.013
SELECT convert(datetime, '10-23-2016', 110) -- mm-dd-yyyy
SELECT convert(datetime, '2016/10/23', 111) -- yyyy/mm/dd
-- YYYYMMDD ISO date format works at any language setting - international standard
SELECT convert(datetime, '20161023')
SELECT convert(datetime, '20161023', 112) -- ISO yyyymmdd
-- 2016-10-23 00:00:00.000
SELECT convert(datetime, '23 Oct 2016 11:02:07:577', 113) -- dd mon yyyy hh:mm:ss:mmm
-- 2016-10-23 11:02:07.577
SELECT convert(datetime, '20:10:25:300', 114) -- hh:mm:ss:mmm(24h)
-- 1900-01-01 20:10:25.300
SELECT convert(datetime, '2016-10-23 20:44:11', 120) -- yyyy-mm-dd hh:mm:ss(24h)
-- 2016-10-23 20:44:11.000
SELECT convert(datetime, '2016-10-23 20:44:11.500', 121) -- yyyy-mm-dd hh:mm:ss.mmm
-- 2016-10-23 20:44:11.500
 
-- Style 126 is ISO 8601 format: international standard - works with any language setting
SELECT convert(datetime, '2008-10-23T18:52:47.513', 126) -- yyyy-mm-ddThh:mm:ss(.mmm)
-- 2008-10-23 18:52:47.513
SELECT convert(datetime, N'23 شوال 1429  6:52:47:513PM', 130) -- Islamic/Hijri date
SELECT convert(datetime, '23/10/1429  6:52:47:513PM',    131) -- Islamic/Hijri date
 
-- Convert DDMMYYYY format to datetime - sql server to date / datetime
SELECT convert(datetime, STUFF(STUFF('31012016',3,0,'-'),6,0,'-'), 105)
-- 2016-01-31 00:00:00.000
-- SQL Server T-SQL string to datetime conversion without century - some exceptions
-- nondeterministic means language setting dependent such as Mar/Mär/mars/márc
SELECT convert(datetime, 'Oct 23 16 11:02:44AM') -- Default
SELECT convert(datetime, '10/23/16', 1) -- mm/dd/yy U.S.
SELECT convert(datetime, '16.10.23', 2) -- yy.mm.dd ANSI
SELECT convert(datetime, '23/10/16', 3) -- dd/mm/yy UK/FR
SELECT convert(datetime, '23.10.16', 4) -- dd.mm.yy German
SELECT convert(datetime, '23-10-16', 5) -- dd-mm-yy Italian
SELECT convert(datetime, '23 OCT 16', 6) -- dd mon yy non-det.
SELECT convert(datetime, 'Oct 23, 16', 7) -- mon dd, yy non-det.
SELECT convert(datetime, '20:10:44', 8) -- hh:mm:ss
SELECT convert(datetime, 'Oct 23 16 11:02:44:013AM', 9) -- Default with msec
SELECT convert(datetime, '10-23-16', 10) -- mm-dd-yy U.S.
SELECT convert(datetime, '16/10/23', 11) -- yy/mm/dd Japan
SELECT convert(datetime, '161023', 12) -- yymmdd ISO
SELECT convert(datetime, '23 Oct 16 11:02:07:577', 13) -- dd mon yy hh:mm:ss:mmm EU dflt
SELECT convert(datetime, '20:10:25:300', 14) -- hh:mm:ss:mmm(24h)
SELECT convert(datetime, '2016-10-23 20:44:11',20) -- yyyy-mm-dd hh:mm:ss(24h) ODBC can.
SELECT convert(datetime, '2016-10-23 20:44:11.500', 21)-- yyyy-mm-dd hh:mm:ss.mmm ODBC
------------

-- SQL Datetime Data Type: Combine date & time string into datetime - sql hh mm ss
-- String to datetime - mssql datetime - sql convert date - sql concatenate string
DECLARE @DateTimeValue varchar(32), @DateValue char(8), @TimeValue char(6)
 
SELECT @DateValue = '20120718',
       @TimeValue = '211920'
SELECT @DateTimeValue =
convert(varchar, convert(datetime, @DateValue), 111)
+ ' ' + substring(@TimeValue, 1, 2)
+ ':' + substring(@TimeValue, 3, 2)
+ ':' + substring(@TimeValue, 5, 2)
SELECT
DateInput = @DateValue, TimeInput = @TimeValue,
DateTimeOutput = @DateTimeValue;
/*
DateInput   TimeInput   DateTimeOutput
20120718    211920      2012/07/18 21:19:20 */