-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Parallel Query

-- =============================================

--How It Works: Maximizing Max Degree Of Parallelism (MAXDOP)
--https://blogs.msdn.microsoft.com/psssql/2013/09/27/how-it-works-maximizing-max-degree-of-parallelism-maxdop/

--Stage 1 – Compile

--If hint is present and > 1 then build a parallel plan

--else if no hint or hint (MAXDOP = 0)

--          if sp_configure setting is 1 but workload group > 1 then build a parallel plan

--           else if sp_configure setting is 0 or > 1 then build parallel plan



--Stage 2 – Query Execution

--if sp_configure or query hint forcing serial plan use (1)

--else if resource workgroup set

--    if query hint present use min(hint, resource workgroup)

--     else use resource workgroup


