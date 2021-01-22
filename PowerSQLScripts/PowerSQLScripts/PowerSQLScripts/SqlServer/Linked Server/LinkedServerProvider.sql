
--SQL 2014 not support Linked server to SQL 2000 workaround
--安裝並使用SQL Server Native Client 10.0
--或使用ODBC DSN

--安裝Third-party Provider (例如Oracle Provider)
EXEC master.dbo.xp_enum_oledb_providers;

--Provider Name	Parse Name	Provider Description
--SQLOLEDB	{0C7FF16C-38E3-11d0-97AB-00C04FC2AD98}	Microsoft OLE DB Provider for SQL Server
--SQLNCLI11	{397C2819-8272-4532-AD3A-FB5E43BEAA39}	SQL Server Native Client 11.0
--OraOLEDB.Oracle	{3F63C36E-51A3-11D2-BB7D-00C04FA30080}	Oracle Provider for OLE DB
--ADsDSOObject	{549365d0-ec26-11cf-8310-00aa00b505db}	OLE DB Provider for Microsoft Directory Services
--MSOLEDBSQL	{5A23DE84-1D7B-4A16-8DED-B29C09CB648D}	Microsoft OLE DB Driver for SQL Server
--Search.CollatorDSO	{9E175B8B-F52A-11D8-B9A5-505054503030}	Microsoft OLE DB Provider for Search
--SSISOLEDB	{AE803C3F-76D3-42EF-A9DC-D90879BDF008}	OLE DB Provider for SQL Server Integration Services
--MSDASQL	{c8b522cb-5cf3-11ce-ade5-00aa0044773d}	Microsoft OLE DB Provider for ODBC Drivers
--MSOLAP	{DBC724B0-DD86-4772-BB5A-FCC6CAB2FC1A}	Microsoft OLE DB Provider for Analysis Services 14.0
--MSDAOSP	{dfc8bdc0-e378-11d0-9b30-0080c7e9fe95}	Microsoft OLE DB Simple Provider

