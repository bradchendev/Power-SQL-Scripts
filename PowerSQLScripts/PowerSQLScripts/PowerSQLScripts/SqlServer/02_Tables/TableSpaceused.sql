

SELECT 
OBJECT_SCHEMA_NAME(i.OBJECT_ID) as [Schema],
OBJECT_NAME(i.OBJECT_ID ) as [Table],
i.name as [Index],
SUM(s.used_page_count) / 128.0 as [IndexSizeinMB]
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE i.type_desc = 'CLUSTERED COLUMNSTORE'
--WHERE i.type_desc = 'NONCLUSTERED COLUMNSTORE'
--WHERE i.type_desc = 'CLUSTERED'
--WHERE i.type_desc = 'NONCLUSTERED'
--WHERE i.type_desc = 'HEAP'
GROUP BY i.OBJECT_ID, i.name

--Schema	Table	Index	IndexSizeinMB
--dbo	CPK_Comp	CCI_CPK_Comp	1153248.437500
--dbo	KNSLOG_Tr	PK_KNSLOG_Tr	517.140625
--dbo	OP20_Tr	PK_OP20_Tr	1083350.468750
--dbo	OP70_Tr_old	PK_OP70_Tr	1070.601562
--dbo	OP50_Tr	PK_OP50_Tr_2	165093.414062
--dbo	OP70_Tr	PK_OP70_Tr_2	12997.578125
--dbo	OP30_Tr	PK_OP30_Tr	767209.484375
--dbo	OP40_Tr	PK_OP40_Tr	2048848.593750
--dbo	SEFF_Tr	PK_SEFF_Tr	2645726.070312
--dbo	SMNF_Tr	PK_SMNF_Tr	93258.781250
--dbo	CSV_List	PK_CSV_List	55340.593750
--dbo	SEDF_Tr	PK_SEDF_Tr	3499011.570312
--dbo	OP70_Tr_test	PK_OP70_Tr_test	0.015625
--dbo	OP70_Tr_2	PK_OP70_Tr_test	0.015625


EXEC sp_spaceused N'dbo.OP70_Tr';  
GO
--name	rows	reserved	data	index_size	unused
--OP70_Tr	66866542            	13736952 KB	13249520 KB	60000 KB	427432 KB
