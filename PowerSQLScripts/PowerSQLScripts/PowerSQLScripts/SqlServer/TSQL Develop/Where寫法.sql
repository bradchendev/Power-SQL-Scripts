-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Where寫法

-- =============================================

declare @p1 nvarchar(10) = N'寫入'
SELECT TOP 1000 [c1]
      ,[c2]
      ,[c3]
  FROM [TESTDB1].[dbo].[Table_9]
  where c2 like @p1+'%'
  
  
  --效能
  declare @_date varchar(10)
  
session_sn like @_date+'%'  
-- 比 
LEFT(session_sn, 8) = @_date
-- 好





-- 比對日期
Declare @birth datetime = '1990/1/1 03:00:00'
Declare @Date datetime = '1990/3/1 03:00:00'

select DAY(@Date)
select month(@Date)


-- 只比對月與日 
where datepart(month,[birth]) = datepart(month,@Date) and datepart(day,[birth]) = datepart(day,@Date)

可考慮改用
WHERE month([birth]) = month(@Date) and DAY([birth]) = DAY(@Date)
 
 

-- 比對年月日
-- 如果 birth裡面的資料只有年月日沒有時間(例如 1972/8/1 00:00:00)，則可以用
[birth] = cast(cast(@Date as date) as datetime)







--  動態WHERE條件
            WHERE   edfd.Quantity > 0
                    AND CASE WHEN @_OrderNo != '' THEN edfm.orderNo
                             ELSE @_OrderNo
                        END = @_OrderNo
                    AND CASE WHEN @_SenderNo != '' THEN edfm.senderNo
                             ELSE @_SenderNo
                        END = @_SenderNo
                    AND CASE WHEN @_Status != '' THEN edfm.Status
                             ELSE @_Status
                        END = @_Status
                       -- 日期區間，若NULL也會成立，就是沒有此條件(將會取到最大)
                    AND ( @_Start IS NULL
                          OR edfm.CreatedAt >= @_Start
                        )
                    AND ( @_End IS NULL
                          OR edfm.CreatedAt < @_End
                        )

