

SELECT S.name as 'Schema',
T.name as 'Table',
I.name as 'Index',
DDIPS.avg_fragmentation_in_percent,
DDIPS.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
INNER JOIN sys.schemas S on T.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
and I.name is not null
AND DDIPS.avg_fragmentation_in_percent > 0
ORDER BY DDIPS.avg_fragmentation_in_percent desc



-- Optimize index maintenance to improve query performance and reduce resource consumption
-- https://docs.microsoft.com/en-us/sql/relational-databases/indexes/reorganize-and-rebuild-indexes?view=sql-server-ver15
-- To check the fragmentation and page density of a rowstore index using Transact-SQL
SELECT OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
       OBJECT_NAME(ips.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       ips.avg_fragmentation_in_percent,
       ips.avg_page_space_used_in_percent,
       ips.page_count,
       ips.alloc_unit_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(), default, default, default, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i 
ON ips.object_id = i.object_id
   AND
   ips.index_id = i.index_id
ORDER BY page_count DESC;

--schema_name  object_name           index_name                               index_type    avg_fragmentation_in_percent avg_page_space_used_in_percent page_count  alloc_unit_type_desc
-------------- --------------------- ---------------------------------------- ------------- ---------------------------- ------------------------------ ----------- --------------------
--dbo          FactProductInventory  PK_FactProductInventory                  CLUSTERED     0.390015600624025            99.7244625648629               3846        IN_ROW_DATA
--dbo          DimProduct            PK_DimProduct_ProductKey                 CLUSTERED     0                            89.6839757845318               497         LOB_DATA
--dbo          DimProduct            PK_DimProduct_ProductKey                 CLUSTERED     0                            80.7132814430442               251         IN_ROW_DATA
--dbo          FactFinance           NULL                                     HEAP          0                            99.7982456140351               239         IN_ROW_DATA
--dbo          ProspectiveBuyer      PK_ProspectiveBuyer_ProspectiveBuyerKey  CLUSTERED     0                            98.1086236718557               79          IN_ROW_DATA
--dbo          DimCustomer           IX_DimCustomer_CustomerAlternateKey      NONCLUSTERED  0                            99.5197553743514               78          IN_ROW_DATA


-- To check the fragmentation of a columnstore index using Transact-SQL
SELECT OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
       OBJECT_NAME(i.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       100.0 * (ISNULL(SUM(rgs.deleted_rows), 0)) / NULLIF(SUM(rgs.total_rows), 0) AS avg_fragmentation_in_percent
FROM sys.indexes AS i
INNER JOIN sys.dm_db_column_store_row_group_physical_stats AS rgs
ON i.object_id = rgs.object_id
   AND
   i.index_id = rgs.index_id
WHERE rgs.state_desc = 'COMPRESSED'
GROUP BY i.object_id, i.index_id, i.name, i.type_desc
ORDER BY schema_name, object_name, index_name, index_type;

--schema_name  object_name            index_name                           index_type                avg_fragmentation_in_percent
-------------- ---------------------- ------------------------------------ ------------------------- ----------------------------
--Sales        InvoiceLines           NCCX_Sales_InvoiceLines              NONCLUSTERED COLUMNSTORE  0.000000000000000
--Sales        OrderLines             NCCX_Sales_OrderLines                NONCLUSTERED COLUMNSTORE  0.000000000000000
--Warehouse    StockItemTransactions  CCX_Warehouse_StockItemTransactions  CLUSTERED COLUMNSTORE     4.225346161484279



