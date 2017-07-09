-- =============================================
-- Author:		Brad Chen
-- https://github.com/bradchendev/Power-SQL-Scripts
-- https://blogs.msdn.microsoft.com/bradchen/
-- Create date: 2017/7/9
-- Description:	Reporting Service

-- =============================================


--Retrieve SSRS report server database information
--https://blogs.technet.microsoft.com/dbtechresource/2015/04/04/retrieve-ssrs-report-server-database-information/

-- Get list of Reports available in Reportserver Database
use ReportServer;
go
Select Name,Path,CreationDate,ModifiedDate from Catalog;
go
Select Name,Path,CreationDate,ModifiedDate from Catalog Where Name ='Simple Test Report.rdl'
go



-- Show owner details of specific report
Select C.Name,C.Path,U.UserName,C.CreationDate,C.ModifiedDate from Catalog C
INNER Join Users U ON C.CreatedByID=U.UserID
Where C.Name ='Simple Test Report.rdl'

-- Search in report server database for specific object
With Reports
AS
(
Select Name as ReportName,CONVERT(Varchar(Max),CONVERT(VARBINARY(MAX),Content)) AS ReportContent from  
Catalog Where Name is NOT NULL
)
Select ReportName from Reports Where ReportContent like '%tablename%'


--Get all available Datasource information in Report server database
Select distinct Name from DataSource Where Name is NOT NULL


-- Get Datasource Information of specific report
Declare @Namespace NVARCHAR(500)
Declare @SQL   VARCHAR(max)
Declare  @ReportName NVARCHAR(850)
SET @ReportName='Simple Test Report.rdl'

SELECT @Namespace= SUBSTRING(
				   x.CatContent  
				  ,x.CIndex
				  ,CHARINDEX('"',x.CatContent,x.CIndex+7) - x.CIndex
				)
	  FROM
     (
		 SELECT CatContent = CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)))
				,CIndex    = CHARINDEX('xmlns="',CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content))))
		   FROM Reportserver.dbo.Catalog C
		  WHERE C.Content is not null
			AND C.Type  = 2
	 ) X

SELECT @Namespace = REPLACE(@Namespace,'xmlns="','') + ''
SELECT @SQL = 'WITH XMLNAMESPACES ( DEFAULT ''' + @Namespace +''', ''http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'' AS rd )
				SELECT  ReportName		 = name
					   ,DataSourceName	 = x.value(''(@Name)[1]'', ''VARCHAR(250)'') 
					   ,DataProvider	 = x.value(''(ConnectionProperties/DataProvider)[1]'',''VARCHAR(250)'')
					   ,ConnectionString = x.value(''(ConnectionProperties/ConnectString)[1]'',''VARCHAR(250)'')
				  FROM (  SELECT top 1 C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
						   FROM  ReportServer.dbo.Catalog C
						  WHERE  C.Content is not null
							AND  C.Type  = 2
							AND  C.Name  = ''' + @ReportName + '''
				  ) a
				  CROSS APPLY reportXML.nodes(''/Report/DataSources/DataSource'') r ( x )
				ORDER BY name ;'

EXEC(@SQL)


-- Get Available Parameter with details in specific Report

SELECT Name as ReportName
		,ParameterName = Paravalue.value('Name[1]', 'VARCHAR(250)') 
	   ,ParameterType = Paravalue.value('Type[1]', 'VARCHAR(250)') 
	   ,ISNullable = Paravalue.value('Nullable[1]', 'VARCHAR(250)') 
	   ,ISAllowBlank = Paravalue.value('AllowBlank[1]', 'VARCHAR(250)') 
	   ,ISMultiValue = Paravalue.value('MultiValue[1]', 'VARCHAR(250)') 
	   ,ISUsedInQuery = Paravalue.value('UsedInQuery[1]', 'VARCHAR(250)') 
	   ,ParameterPrompt = Paravalue.value('Prompt[1]', 'VARCHAR(250)') 
	   ,DynamicPrompt = Paravalue.value('DynamicPrompt[1]', 'VARCHAR(250)') 
	   ,PromptUser = Paravalue.value('PromptUser[1]', 'VARCHAR(250)') 
	   ,State = Paravalue.value('State[1]', 'VARCHAR(250)') 
 FROM (  
		 SELECT top 1 C.Name,CONVERT(XML,C.Parameter) AS ParameterXML
		   FROM  ReportServer.dbo.Catalog C
		  WHERE  C.Content is not null
		AND  C.Type  = 2
		AND  C.Name  =  'Simple Test Report.rdl'
	  ) a
CROSS APPLY ParameterXML.nodes('//Parameters/Parameter') p ( Paravalue )

-- Recover report RDL file from report server database
Select Name as ReportName,CONVERT(XML,CONVERT(VARBINARY(MAX),Content)) AS ReportContent from  
Catalog Where Name ='Simple Test Report.rdl'


--Get configuration information of Report Server database
Select Name,Value from ConfigurationInfo

--Get available roles in Report Server
Select RoleName,Description from Roles

--Get Report Server Machine Name where Report server database is configured
Select MachineName,InstallationID,InstanceName,Client,PublicKey,SymmetricKey from Keys
Where MachineName IS NOT NULL
