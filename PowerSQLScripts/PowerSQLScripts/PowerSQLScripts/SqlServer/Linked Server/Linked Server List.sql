-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/8
-- Description:	Linked Servers 

-- =============================================


-- v2
SELECT ss.server_id 
          ,ss.name 
          ,'Server ' = Case ss.Server_id 
                            when 0 then 'Current Server' 
                            else 'Remote Server' 
                            end 
          ,ss.product 
          ,ss.provider 
          ,ss.data_source
          ,ss.catalog 
          , sl.uses_self_credential 
          ,'Uses Self Credentials' = sl.uses_self_credential 
           ,'local login name' = ssp.name
           ,'Remote Login Name' = sl.remote_name 
           ,'RPC Out Enabled'    = case ss.is_rpc_out_enabled 
                                   when 1 then 'True' 
                                   else 'False' 
                                   end 
           ,'Data Access Enabled' = case ss.is_data_access_enabled 
                                    when 1 then 'True' 
                                    else 'False' 
                                    end 
           ,ss.modify_date 
      FROM sys.Servers ss 
 LEFT JOIN sys.linked_logins sl 
        ON ss.server_id = sl.server_id 
 LEFT JOIN sys.server_principals ssp 
        ON ssp.principal_id = sl.local_principal_id
        
--v1
--SELECT ss.server_id 
--          ,ss.name 
--          ,'Server ' = Case ss.Server_id 
--                            when 0 then 'Current Server' 
--                            else 'Remote Server' 
--                            end 
--          ,ss.product 
--          ,ss.provider 
--          ,ss.data_source
--          ,ss.catalog 
--          ,'Local Login ' = case sl.uses_self_credential 
--                            when 1 then 'Uses Self Credentials' 
--                            else ssp.name 
--                            end 
--           ,'Remote Login Name' = sl.remote_name 
--           ,'RPC Out Enabled'    = case ss.is_rpc_out_enabled 
--                                   when 1 then 'True' 
--                                   else 'False' 
--                                   end 
--           ,'Data Access Enabled' = case ss.is_data_access_enabled 
--                                    when 1 then 'True' 
--                                    else 'False' 
--                                    end 
--           ,ss.modify_date 
--      FROM sys.Servers ss 
-- LEFT JOIN sys.linked_logins sl 
--        ON ss.server_id = sl.server_id 
-- LEFT JOIN sys.server_principals ssp 
--        ON ssp.principal_id = sl.local_principal_id


-- 
-- https://support.microsoft.com/en-us/kb/203638
--sp_linkedservers
--sp_tables_ex
--sp_columns_ex

-- 
-- sys.servers (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms178530.aspx
-- server_id	int	Local ID of linked server.
--
--SELECT * FROM sys.servers
--WHERE server_id > 0

-- sys.remote_logins (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms177584.aspx


-- sys.linked_logins (Transact-SQL)
-- https://msdn.microsoft.com/en-us/library/ms188018(v=sql.105).aspx



--Column name	Data type	Description	
--server_id int ID of the server in sys.servers.
--local_principal_id int Server-principal to whom mapping applies. 0 = wildcard or public.
--uses_self_credential bit If 1, mapping indicates session should use its own credentials; otherwise, 0 indicates that session uses the name and password that are supplied.
--remote_name sysname Remote user name to use when connecting. Password is also stored, but not exposed in catalog view interfaces.
--modify_date datetime Date the linked login was last changed.

