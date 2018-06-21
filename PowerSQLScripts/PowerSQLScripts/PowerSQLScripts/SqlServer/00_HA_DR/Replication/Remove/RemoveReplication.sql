-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date/update: 2018/06/15
-- Description:	Dropping the transactional subscriptions, publication, cleanup on Subscriber
--
-- 在發行者Publisher的Replication Node，右擊Generate Script，只會產生刪除發行者的複寫設定，訂閱者會留下未清除的設定，需手動連接到訂閱者的replication node, Local Subscription手動刪除或執行以下語法逐一刪除
-- 也可以用以下方法在散發者，產生所有發行集的sp_subscription_cleanup語法script
--
-- =============================================


-- Dropping the transactional subscriptions
use [muchnewdb]
exec sp_dropsubscription @publication = N'TestPub1', @subscriber = N'TPELOGDB1', @destination_db = N'muchnewdb', @article = N'all'
GO
-- Dropping the transactional articles
use [muchnewdb]
exec sp_dropsubscription @publication = N'TestPub1', @article = N'cfg_product', @subscriber = N'all', @destination_db = N'all'
GO
use [muchnewdb]
exec sp_droparticle @publication = N'TestPub1', @article = N'cfg_product', @force_invalidate_snapshot = 1
GO
-- Dropping the transactional publication
use [muchnewdb]
exec sp_droppublication @publication = N'TestPub1'
GO



-- 在發行者Publisher的Replication Node，右擊Generate Script，無法產生以下語法，訂閱者會留下未清除的設定，需手動連接到訂閱者的replication node, Local Subscription手動刪除或執行以下語法逐一刪除
-- run  at the Subscriber on the subscription database
EXEC sp_subscription_cleanup @publisher = N'TPEMGNDB', @publisher_db = 'muchnewdb', @publication = N'TestPub1' 

-- 也可以用以下方法在散發者，產生所有發行集的sp_subscription_cleanup語法script
-- Generate  sp_subscription_cleanup script
--select 
--'EXEC sp_subscription_cleanup @publisher = N''' + svr.name + ''', @publisher_db = ''' + pub.publisher_db + ''', @publication = N''' + pub.publication + '''; '
-- from distribution.dbo.MSpublications as pub
--inner join sys.servers as svr on pub.publisher_id = svr.server_id
-- where svr.name = 'YourServerName'