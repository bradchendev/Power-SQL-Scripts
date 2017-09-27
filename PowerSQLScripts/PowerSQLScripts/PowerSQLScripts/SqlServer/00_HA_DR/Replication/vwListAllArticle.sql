-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/9/27
-- Description:	vwListAllArticles

-- =============================================

CREATE VIEW vwListAllArticles
AS
SELECT 
pub.publication
      ,art.[publisher_db]
      ,art.[article]
		, art.[publisher_id]
      ,art.[publication_id]
      ,art.[article_id]
      ,art.[destination_object]
      ,art.[source_owner]
      ,art.[source_object]
      ,art.[description]
      ,art.[destination_owner]
  FROM [distribution].[dbo].[MSarticles] as art
 inner join [distribution].dbo.MSpublications as pub
 on art.publication_id = pub.publication_id