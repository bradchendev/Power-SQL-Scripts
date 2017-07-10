-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/11
-- Description:	Datetime Datediff

-- =============================================

--DATEDIFF (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms189794.aspx

--DATEDIFF ( datepart , startdate , enddate ) 
--datepart	Abbreviations
--year	yy, yyyy
--quarter	qq, q
--month	mm, m
--dayofyear	dy, y
--day	dd, d
--week	wk, ww
--hour	hh
--minute	mi, n
--second	ss, s
--millisecond	ms
--microsecond	mcs
--nanosecond	ns

SELECT DATEDIFF(year, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(quarter, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(month, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(dayofyear, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(day, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(week, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(hour, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(minute, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(second, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');
SELECT DATEDIFF(millisecond, '2005-12-31 23:59:59.9999999'
, '2006-01-01 00:00:00.0000000');