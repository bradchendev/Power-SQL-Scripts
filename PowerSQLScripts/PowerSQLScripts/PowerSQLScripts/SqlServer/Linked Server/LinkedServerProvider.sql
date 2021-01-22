

--安裝Third-party Provider (例如Oracle Provider)
EXEC master.dbo.xp_enum_oledb_providers;

--SQL 2014 not support Linked server to SQL 2000 workaround
--安裝並使用SQL Server Native Client 10.0
--或使用ODBC DSN
