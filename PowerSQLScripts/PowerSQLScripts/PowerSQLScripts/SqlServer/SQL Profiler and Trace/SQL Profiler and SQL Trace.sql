-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	SQL Profiler and SQL Trace
-- sp_trace_setevent (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-setevent-transact-sql
-- =============================================

SELECT ca.name,
ev.name,
ev.trace_event_id,
ca.category_id
 FROM 
sys.trace_categories ca
inner join 
sys.trace_events ev
on ca.category_id = ev.category_id
where ca.name = 'Performance'

select * from sys.trace_columns


-- =============================================
SELECT * FROM sys.trace_categories
--category_id	name	type
--1	Cursors	0
--2	Database	0
--3	Errors and Warnings	2
--4	Locks	0
--5	Objects	0
--6	Performance	0
--7	Scans	0
--8	Security Audit	0
--9	Server	0
--10	Sessions	1
--11	Stored Procedures	0
--12	Transactions	0
--13	TSQL	0
--14	User configurable	0
--15	OLEDB	0
--16	Broker	0
--17	Full text	0
--18	Deprecation	0
--19	Progress Report	0
--20	CLR	0
--21	Query Notifications	0


SELECT * FROM sys.trace_events


--trace_event_id	category_id	name
--10	11	RPC:Completed
--11	11	RPC:Starting
--12	13	SQL:BatchCompleted
--13	13	SQL:BatchStarting
--14	8	Audit Login
--15	8	Audit Logout
--16	3	Attention
--17	10	ExistingConnection
--18	8	Audit Server Starts And Stops
--19	12	DTCTransaction
--20	8	Audit Login Failed
--21	3	EventLog
--22	3	ErrorLog
--23	4	Lock:Released
--24	4	Lock:Acquired
--25	4	Lock:Deadlock
--26	4	Lock:Cancel
--27	4	Lock:Timeout
--28	6	Degree of Parallelism
--33	3	Exception
--34	11	SP:CacheMiss
--35	11	SP:CacheInsert
--36	11	SP:CacheRemove
--37	11	SP:Recompile
--38	11	SP:CacheHit
--40	13	SQL:StmtStarting
--41	13	SQL:StmtCompleted
--42	11	SP:Starting
--43	11	SP:Completed
--44	11	SP:StmtStarting
--45	11	SP:StmtCompleted
--46	5	Object:Created
--47	5	Object:Deleted
--50	12	SQLTransaction
--51	7	Scan:Started
--52	7	Scan:Stopped
--53	1	CursorOpen
--54	12	TransactionLog
--55	3	Hash Warning
--58	6	Auto Stats
--59	4	Lock:Deadlock Chain
--60	4	Lock:Escalation
--61	15	OLEDB Errors
--67	3	Execution Warnings
--68	6	Showplan Text (Unencoded)
--69	3	Sort Warnings
--70	1	CursorPrepare
--71	13	Prepare SQL
--72	13	Exec Prepared SQL
--73	13	Unprepare SQL
--74	1	CursorExecute
--75	1	CursorRecompile
--76	1	CursorImplicitConversion
--77	1	CursorUnprepare
--78	1	CursorClose
--79	3	Missing Column Statistics
--80	3	Missing Join Predicate
--81	9	Server Memory Change
--82	14	UserConfigurable:0
--83	14	UserConfigurable:1
--84	14	UserConfigurable:2
--85	14	UserConfigurable:3
--86	14	UserConfigurable:4
--87	14	UserConfigurable:5
--88	14	UserConfigurable:6
--89	14	UserConfigurable:7
--90	14	UserConfigurable:8
--91	14	UserConfigurable:9
--92	2	Data File Auto Grow
--93	2	Log File Auto Grow
--94	2	Data File Auto Shrink
--95	2	Log File Auto Shrink
--96	6	Showplan Text
--97	6	Showplan All
--98	6	Showplan Statistics Profile
--100	11	RPC Output Parameter
--102	8	Audit Database Scope GDR Event
--103	8	Audit Schema Object GDR Event
--104	8	Audit Addlogin Event
--105	8	Audit Login GDR Event
--106	8	Audit Login Change Property Event
--107	8	Audit Login Change Password Event
--108	8	Audit Add Login to Server Role Event
--109	8	Audit Add DB User Event
--110	8	Audit Add Member to DB Role Event
--111	8	Audit Add Role Event
--112	8	Audit App Role Change Password Event
--113	8	Audit Statement Permission Event
--114	8	Audit Schema Object Access Event
--115	8	Audit Backup/Restore Event
--116	8	Audit DBCC Event
--117	8	Audit Change Audit Event
--118	8	Audit Object Derived Permission Event
--119	15	OLEDB Call Event
--120	15	OLEDB QueryInterface Event
--121	15	OLEDB DataRead Event
--122	6	Showplan XML
--123	6	SQL:FullTextQuery
--124	16	Broker:Conversation
--125	18	Deprecation Announcement
--126	18	Deprecation Final Support
--127	3	Exchange Spill Event
--128	8	Audit Database Management Event
--129	8	Audit Database Object Management Event
--130	8	Audit Database Principal Management Event
--131	8	Audit Schema Object Management Event
--132	8	Audit Server Principal Impersonation Event
--133	8	Audit Database Principal Impersonation Event
--134	8	Audit Server Object Take Ownership Event
--135	8	Audit Database Object Take Ownership Event
--136	16	Broker:Conversation Group
--137	3	Blocked process report
--138	16	Broker:Connection
--139	16	Broker:Forwarded Message Sent
--140	16	Broker:Forwarded Message Dropped
--141	16	Broker:Message Classify
--142	16	Broker:Transmission
--143	16	Broker:Queue Disabled
--144	16	Broker:Mirrored Route State Changed
--146	6	Showplan XML Statistics Profile
--148	4	Deadlock graph
--149	16	Broker:Remote Message Acknowledgement
--150	9	Trace File Close
--151	2	Database Mirroring Connection
--152	8	Audit Change Database Owner
--153	8	Audit Schema Object Take Ownership Event
--154	8	Audit Database Mirroring Login
--155	17	FT:Crawl Started
--156	17	FT:Crawl Stopped
--157	17	FT:Crawl Aborted
--158	8	Audit Broker Conversation
--159	8	Audit Broker Login
--160	16	Broker:Message Undeliverable
--161	16	Broker:Corrupted Message
--162	3	User Error Message
--163	16	Broker:Activation
--164	5	Object:Altered
--165	6	Performance statistics
--166	13	SQL:StmtRecompile
--167	2	Database Mirroring State Change
--168	6	Showplan XML For Query Compile
--169	6	Showplan All For Query Compile
--170	8	Audit Server Scope GDR Event
--171	8	Audit Server Object GDR Event
--172	8	Audit Database Object GDR Event
--173	8	Audit Server Operation Event
--175	8	Audit Server Alter Trace Event
--176	8	Audit Server Object Management Event
--177	8	Audit Server Principal Management Event
--178	8	Audit Database Operation Event
--180	8	Audit Database Object Access Event
--181	12	TM: Begin Tran starting
--182	12	TM: Begin Tran completed
--183	12	TM: Promote Tran starting
--184	12	TM: Promote Tran completed
--185	12	TM: Commit Tran starting
--186	12	TM: Commit Tran completed
--187	12	TM: Rollback Tran starting
--188	12	TM: Rollback Tran completed
--189	4	Lock:Timeout (timeout > 0)
--190	19	Progress Report: Online Index Operation
--191	12	TM: Save Tran starting
--192	12	TM: Save Tran completed
--193	3	Background Job Error
--194	15	OLEDB Provider Information
--195	9	Mount Tape
--196	20	Assembly Load
--198	13	XQuery Static Type
--199	21	QN: Subscription
--200	21	QN: Parameter table
--201	21	QN: Template
--202	21	QN: Dynamics
--212	3	Bitmap Warning
--213	3	Database Suspect Data Page
--214	3	CPU threshold exceeded
--215	10	PreConnect:Starting
--216	10	PreConnect:Completed
--217	6	Plan Guide Successful
--218	6	Plan Guide Unsuccessful
--235	8	Audit Fulltext




-- read default trace
SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.Duration ,
        t.StartTime ,
        t.EndTime,
        t.ObjectName 
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
--WHERE   te.name = 'Data File Auto Grow'
--        OR te.name = 'Data File Auto Shrink'
ORDER BY t.StartTime ; 

--Troubleshooting and Analysis with Traces
--https://msdn.microsoft.com/en-us/library/cc293616.aspx

-- 1.先從以下Event
--Stored Procedures:RPC:Completed
--TSQL:SQL:BatchCompleted

-- 2.欄位
-- adding the TextData, Reads, Writes, and CPU columns for both events

-- 3.filter
-- Most of the active OLTP systems 
-- we generally start with the filter set to 100 milliseconds

-- 4.收集時間
-- generally run each iterative trace for 10 to 15 minutes, depending on server load
-- Note that the 10- to 15-minute figure may be too high for some extremely busy applications. 

-- 5.Analysis
-- To see only the top 10 percent of queries in a trace table, based on duration, use the following query:
	SELECT * 
	FROM 
		(
		SELECT *, NTILE(10) OVER(ORDER BY Duration) Bucket 
		FROM TraceTable
		) x
	WHERE Bucket = 10;









--Tracing Considerations and Design
--https://msdn.microsoft.com/en-us/library/cc293614.aspx
--The SQL Server Profiler Question
--Reducing Trace Overhead
--Max File Size, Rollover, and Data Collection


--View and Analyze Traces with SQL Server Profiler
--https://msdn.microsoft.com/en-us/library/ms175848.aspx


SELECT  TextData, Duration, CPU  
FROM    trace_table_name  
WHERE   EventClass = 12 -- SQL:BatchCompleted events  
AND     CPU < (Duration * 1000)  


-- SQL Trace
-- Duration 10^-6 (microseconds)
-- CPU 10^-3 (millinseconds)

-- SQL Profiler 
-- displays the Duration column in milliseconds( 10^-3) by default


--The server reports the duration of an event in microseconds (10^-6 seconds) and 
--the amount of CPU time used by the event in milliseconds (10^-3 seconds). 

--The SQL Server Profiler graphical user interface displays the Duration column in milliseconds by default, 
--but when a trace is saved to either a file or a database table, the Duration column value is written in microseconds.





--View a Saved Trace (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms179455.aspx

SELECT *  
FROM ::fn_trace_getinfo(default)

SELECT *  
FROM ::fn_trace_getinfo(trace_id)   



--sys.fn_trace_gettable (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms188425.aspx

--Arguments
--'filename'
--Specifies the initial trace file to be read. filename is nvarchar(256), with no default.
--number_files
--Specifies the number of rollover files to be read. This number includes the initial file specified in filename. number_files is an int.


SELECT * 
FROM fn_trace_gettable('c:\temp\mytrace.trc', default);  
GO  


SELECT * INTO temp_trc  
FROM fn_trace_gettable('c:\temp\mytrace.trc', default);  
GO  


SELECT IDENTITY(int, 1, 1) AS RowNumber, * INTO temp_trc  
FROM fn_trace_gettable('c:\temp\mytrace.trc', default);  
GO  




-- SQL Trace

select * from sys.traces

--status	int	Trace status:
--0 = stopped
--1 = running

--sys.traces (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms178579.aspx


--sp_trace_setstatus 2, 0
--GO

--sp_trace_setstatus 2, 2
--GO

--Status	Description
--0	Stops the specified trace. 
--  will change status to 0
--1	Starts the specified trace.
--2	Closes the specified trace and deletes its definition from the server.
--  will delete record in sys.traces

--sp_trace_setstatus (Transact-SQL)
--https://msdn.microsoft.com/en-us/library/ms176034.aspx


