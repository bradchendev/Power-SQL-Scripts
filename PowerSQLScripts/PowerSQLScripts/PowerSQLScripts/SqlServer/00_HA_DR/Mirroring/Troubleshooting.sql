

--關於wait type發生DBMIRROR_DBM_EVENT時，可以從 鏡像監視器,dbm_monitor_data 表, 效能計數器, ERRORLOG…逐步釐清原因，找出問題發生時要檢查卡在哪一段。

-- SQL Server blocking caused by database mirroring wait type DBMIRROR_DBM_EVENT
-- https://blogs.msdn.microsoft.com/grahamk/2011/01/10/sql-server-blocking-caused-by-database-mirroring-wait-type-dbmirror_dbm_event/

--例如 
-- For example if the send_queue suddenly starts to grow but the re_do queue doesn't grow, then it would imply that the the principal cannot send the log records to the mirror so you'd want to look at connectivity maybe, or the service broker queues dealing with the actual transmissions.
--就是卡在 主要傳送到鏡像中間這段(可能就是卡在網路)

--例如只有Re_do慢，可能就是 鏡像DB Server CPU, Disk性能不足 (要檢查工作管理員或效能計數器…等)

-- Database Mirroring Best Practices and Performance Considerations
-- https://technet.microsoft.com/en-us/library/cc917681.aspx

-- Things to consider when setting up database mirroring in SQL Server.
-- https://support.microsoft.com/zh-tw/help/2001270/things-to-consider-when-setting-up-database-mirroring-in-sql-server

-- Database Mirroring (OLTP)---a Technical Reference Guide for Designing Mission-Critical OLTP Solutions
-- https://technet.microsoft.com/en-us/library/hh393563(v=sql.110).aspx

