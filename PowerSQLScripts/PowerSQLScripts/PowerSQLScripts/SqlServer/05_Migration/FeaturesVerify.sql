-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2020/3/15
-- Description:	查詢資料庫是否啟用了特定功能

-- =============================================

--moving the database on Enterprise to a Standard Edition instance
--啟用企業版功能的資料庫無法還原到標準版

--SQL Server 2005
select * from
   (-- VarDecimal Storage Format
    select case
             when max(objectproperty(object_id, N'TableHasVarDecimalStorageFormat')) = 0
               then ''
             else 'VarDecimal Storage'
           end as Enterprise_feature_name
      from sys.objects
    UNION ALL
    -- Partitioning
    select case
             when max(partition_number) > 1
               then 'Partitioning'
             else ''
           end 
      from sys.partitions
) t
where Enterprise_feature_name <> '';

--SQL Server 2008
select * from sys.dm_db_persisted_sku_features;
