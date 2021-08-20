
-- 如果有兩個Tlog file，但要移除第二個Tlog出現以下錯誤(既使執行了shrinkfile empty並確認virtual file status = 0)
-- Msg 5042, Level 16, State 2, Line 9
-- The file 'MyDB_log2' cannot be removed because it is not empty.


-- 如果出現只有兩筆，一個tlog file一筆，就無法移除 第二個Tlog
-- DBCC LOGINFO('MyDB');
--RecoveryUnitId	FileId	FileSize	StartOffset	FSeqNo	Status	Parity	CreateLSN
--0	2	137438887936	8192	46	2	128	0
--0	19	2031616	8192	0	0	0	0


-- Resolution
-- 加大第一個tlog，讓第一個tlog超過2個Virtual Log File

-- https://desertdba.com/why-cant-i-remove-this-extra-transaction-log-file/

