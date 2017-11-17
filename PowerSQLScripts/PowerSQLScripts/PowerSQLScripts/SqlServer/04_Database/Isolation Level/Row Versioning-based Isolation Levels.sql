-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/11/8
-- Description:	Row Versioning-based Isolation Levels in the Database Engine
-- =============================================




-- Row Versioning-based Isolation Levels in the Database Engine
-- https://technet.microsoft.com/en-us/library/ms177404(v=sql.105).aspx

-- Enabling Row Versioning-Based Isolation Levels
-- https://technet.microsoft.com/en-us/library/ms175095(v=sql.105).aspx

select 
name, 
snapshot_isolation_state_desc,
is_read_committed_snapshot_on
 from sys.databases
where name = 'AdventureWorks2008R2'

-- 
ALTER DATABASE AdventureWorks2008R2
    SET READ_COMMITTED_SNAPSHOT ON;

-- 
ALTER DATABASE AdventureWorks2008R2
    SET ALLOW_SNAPSHOT_ISOLATION ON;

-- ALTER DATABASE啟用時，可能會遇到有session正在使用DB，既使這個session已經sleeping
-- 已下面這個案例 session_id 57已經sleeping
-- 通常需要中斷所有連線才能啟用成功
select 
req.session_id, req.status, req.wait_type, req.wait_resource, req.blocking_session_id
 from sys.dm_exec_sessions se inner join sys.dm_exec_connections con on se.session_id = con.session_id
inner join sys.dm_exec_requests req on req.session_id = se.session_id where se.session_id = 63

--session_id	status	wait_type	wait_resource	blocking_session_id
--63	suspended	LCK_M_X	DATABASE: 43 	57

-- 此時可以等待連線都idle到一定時間(Connection pool約8分鐘)後自動中斷，才能執行ALTER DATABASE
-- 或是執行時加上WITH ROLLBACK IMMEDIATE直接中斷連線。
ALTER DATABASE TWDALSYS
    SET READ_COMMITTED_SNAPSHOT ON
	WITH ROLLBACK IMMEDIATE; 
-- Nonqualified transactions are being rolled back. Estimated rollback completion: 100%.


-- ALTER DATABASE SET Options (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options


-- Choosing Row Versioning-based Isolation Levels
-- https://technet.microsoft.com/en-us/library/ms188277(v=sql.105).aspx

--When to Use Read Committed Isolation Using Row Versioning
--  Read committed isolation using row versioning provides statement-level read consistency. As each statement within the transaction executes, a new data snapshot is taken and remains consistent for each statement until the statement finishes execution. Enable read committed isolation using row versioning when:
--  Reader/writer blocking occurs to the point that concurrency benefits outweigh increased overhead of creating and managing row versions.
--  An application requires absolute accuracy for long-running aggregations or queries where data values must be consistent to the point in time that a query starts.
--When to Use Snapshot Isolation
--  Snapshot isolation provides transaction-level read consistency. A data snapshot is taken when the snapshot transaction starts, and remains consistent for the duration of the transaction. Use snapshot isolation when:
--  Optimistic concurrency control is desired.
--  Probability is low that a transaction would have to be rolled back because of an update conflict.
--  An application needs to generate reports based on long-running, multi-statement queries that must have point-in-time consistency. Snapshot isolation provides the benefit of repeatable reads (see Concurrency Effects) without using shared locks. Database snapshot can provide similar functionality but must be implemented manually. Snapshot isolation automatically provides the latest information in the database for each snapshot isolation transaction.


--以資料列版本控制為基礎的隔離等級會刪除讀取作業的鎖定，來改善讀取並行。Microsoft SQL Server 引進了兩個使用資料列版本控制的交易隔離等級：
--  讀取認可隔離的新實作，會在 READ_COMMITTED_SNAPSHOT 資料庫選項為 ON 時，使用資料列版本控制。
--  新的隔離等級 (快照集)，是在 ALLOW_SNAPSHOT_ISOLATION 資料庫選項為 ON 時啟用。

--基於下列理由，建議針對大部份的應用程式使用讀取認可隔離，而非快照集隔離：
--  它所消耗的 tempdb 空間會比快照集隔離少。
--  它使用分散式交易，但快照集隔離不是。
--  它可與大部份現有的應用程式一起運作，而不需任何變更。使用預設隔離等級 (讀取認可) 撰寫的應用程式可進行動態微調。不管是否使用資料列版本控制，讀取認可的行為都是由資料庫選項設定所決定，而且這個設定可以變更，不會影響到應用程式。

--附註附註
--  對於設計來相依於讀取認可隔離之封鎖行為的應用程式，開發人員可能想改變應用程式，以使用讀取認可隔離的兩種模式。除此以外，也須注意 READ_COMMITTED_SNAPSHOT 資料庫選項仍為 OFF。
--  快照集隔離很容易發生更新衝突，而這些衝突不適用於使用資料列版本控制的讀取認可隔離。若快照集隔離下執行之交易所讀取的資料隨後會由另一個交易所修改，則快照集交易對相同資料所做的更新會導致更新衝突，交易會因而終止並回復。這不是與使用資料列版本控制之讀取認可隔離有關的問題。


--使用版本控制之讀取認可隔離的使用時機
--使用資料列版本控制的讀取認可隔離提供了陳述式等級的讀取一致性。執行交易內的每一個陳述式時，會取得新的資料快照集，且會對每個陳述式保持一致性，直到陳述式完成執行。發生下列情況時，會啟用使用資料列版本控制的讀取認可隔離：
--  1.發生讀取器/寫入器封鎖的那一時刻，其並行好處超過了因建立及管理資料列版本所造成的負擔。
--  2.應用程式會對長期執行的彙總或查詢要求絕對的精準度，即資料值必須與查詢一開始的時間點一致。

--使用快照集隔離的時機
--快照集隔離提供了交易等級的讀取一致性。快照集交易開始時，即會取得資料快照集，並於交易期間保持一致。發生下列情況時，可使用快照集隔離：
--  1.需要開放式 (Optimistic) 並行控制。
--  2.交易因更新衝突而需回復的機率不高。
--  3.應用程式需要根據長期執行且需具時間點一致性的多重陳述式查詢來產生報表。快照集隔離提供了不需使用共用鎖定即可重複讀取的好處 (請參閱＜並行效果＞)。資料庫快照集可以提供類似功能，但必須手動實作。快照集隔離會自動為每一個快照集隔離交易提供資料庫中的最新資訊。


--以資料列版本控制為基礎之隔離等級的好處
--使用資料列版本控制的隔離等級提供了下列好處：
--1.讀取作業會擷取資料庫的一致快照集。
--2.讀取作業期間，SELECT 陳述式不會鎖定資料 (讀取器不會封鎖寫入器，反之亦然)。
--3.當其他交易正在更新未封鎖的資料列時，SELECT 陳述式可以存取資料列的最後認可值。
--4.減少死結數目。
--5.減少交易所需的鎖定數目，也會減少管理鎖定所需的系統負擔。
--6.較少發生鎖定擴大。
