-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	 鎖定資料表防止其他連線存取Lock table prevent from other session

-- =============================================

begin tran

insert into dbo.Table_9_temp
select * from dbo.Table_9 with (tablockx)
-- 以上就可以鎖住TABLE，其他session無法select/insert/update/delete

truncate table dbo.Table_9 

insert into dbo.Table_9
select * from dbo.Table_9_temp


rollback