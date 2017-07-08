-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Index 查詢索引清單 與狀態
 -- Indexes 
 -- https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes
-- =============================================


-- 從統計資訊更新時間取得，index create date(此時間可能統計資訊更新後最新的日期)
select STATS_DATE(so.object_id, index_id) StatsDate
, si.name IndexName
, schema_name(so.schema_id) + N'.' + so.Name TableName
, so.object_id, si.index_id
from sys.indexes si
inner join sys.tables so on so.object_id = si.object_id
WHERE SI.NAME = 'IX_Table_1_c2'
order by 1 desc



-- index and column
SELECT 
obj.name as [Table Name],
idx.name as [index_name],
idx.type_desc as [index_type],
col.name as [Column_Name],
idx.is_primary_key,
idxCol.is_included_column,
--idx.type,
idx.is_unique,
idx.is_unique_constraint,
idx.ignore_dup_key,
idx.fill_factor,
idx.is_padded,
idx.is_disabled
FROM sys.indexes AS idx
INNER JOIN sys.objects as obj 
	ON obj.object_id=idx.object_id 
	and obj.type = 'U' 
	and idx.is_hypothetical = 0 -- 去除statistic
INNER JOIN sys.index_columns as idxCol
	ON idxCol.object_id = idx.object_id and idxCol.index_id=idx.index_id
inner join sys.columns col on idxCol.object_id=col.object_id and idxCol.column_id = col.column_id
where obj.name = 'Table_1'
order by idx.type, idx.name, idxCol.column_id


-- index and filegroup
SELECT 
obj.name as [Table Name],
idx.name as [index_name],
idx.type_desc as [index_type],
ds.type_desc as filegroup_or_partition_shceme,
ds.name as  filegroup_or_partition_shceme_name,
idx.is_primary_key,
--idx.type,
idx.is_unique,
idx.is_unique_constraint,
idx.ignore_dup_key,
idx.fill_factor,
idx.is_padded,
idx.is_disabled
FROM sys.indexes AS idx
INNER JOIN sys.objects as obj 
	ON obj.object_id=idx.object_id 
	and obj.type = 'U' 
	and idx.is_hypothetical = 0 -- 去除statistic
INNER JOIN sys.data_spaces AS ds ON idx.data_space_id=ds.data_space_id
where obj.name = 'Table_1'
order by idx.type, idx.name
