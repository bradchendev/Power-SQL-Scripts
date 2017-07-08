-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	把多筆資料變成一筆，以逗點分隔

-- =============================================


  -- 語法比較長
SELECT  
	STUFF(
				( SELECT ', ' + [ColumnName] 
					FROM [dbo].[CfgSyncTableList2]
					WHERE DataBaseName = a.DataBaseName
							and SchemaName = a.SchemaName
							and TableName = a.TableName
					FOR XML PATH(''))
					,1,1, ' ') as [ColumnList]
  FROM [dbo].[CfgSyncTableList2] a
  where DataBaseName = 'AdventureWork2008R2' 
  and SchemaName = 'dbo' 
  and TableName = 'Table_1'
  GROUP BY DataBaseName, SchemaName, TableName
  

 
  
  -- 語法比較短

DECLARE @STR nvarchar(4000)
  
SELECT @STR =(
								SELECT '['+CAST(ColumnName AS VARCHAR(100)) + '],'
FROM ETL.dbo.CfgSyncTableList2
WHERE 1 = 1
  and DataBaseName = 'AdventureWork2008R2' 
  and SchemaName = 'dbo' 
  and TableName = 'Table_1'
FOR XML PATH('')
)

SELECT @STR