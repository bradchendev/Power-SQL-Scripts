'----------------------------------------------------------------------------------------------------------------------------  
'Script Name : SQLHealthCheck.vbs     
'Author      : Brad Chen    
'Created     : 2021-03-26
'Description : This script check the health status of a SQL Server with sp_server_diagnostics procedure.  
'
'sp_server_diagnostics (Transact-SQL)
'https://docs.microsoft.com/zh-tw/sql/relational-databases/system-stored-procedures/sp-server-diagnostics-transact-sql?view=sql-server-ver15
'
'CREATE TABLE SpServerDiagnosticsResult  
'(  
'      create_time DateTime,  
'      component_type sysname,  
'      component_name sysname,  
'      state int,  
'      state_desc sysname,  
'      data xml  
');  
'INSERT INTO SpServerDiagnosticsResult  
'EXEC sp_server_diagnostics;
'
'----------------------------------------------------------------------------------------------------------------------------  


'Initialization  Section     
'----------------------------------------------------------------------------------------------------------------------------  
Option Explicit  
Dim healthChkServer, healthChkDb, healthChklogin, healthChkpw
healthChkServer = "xxxx.southeastasia.cloudapp.azure.com"
healthChkDb = "master"
healthChklogin = "monitoruser"
healthChkpw = "yourpassword"

Dim RecServer
RecServer = "(local)"

Dim ErrMsg

On Error Resume Next 
	Dim healthConn, healthSql, healthRs
	Dim recConn, recSql
	
	' Connection for save data into Table
	Set recConn = CreateObject("ADODB.Connection")
	recConn.Open "Provider=SQLOLEDB;Data Source=" & RecServer & ";Initial Catalog=DBA;Integrated Security=SSPI;"

	' 當無法連線到儲存資料的SQL Server，則停止程式
	If Err.Number <> 0 Then 
		Wscript.Echo "Err.Number is " & Err.Number
		Wscript.Echo "Err.Description is " & Err.Description
		Wscript.Quit  
	End If 

	' Connection for Health Check 
	Set healthConn = CreateObject("ADODB.Connection")
	
	healthConn.Open "Provider=SQLOLEDB;Data Source=" & healthChkServer & ";Initial Catalog=" & healthChkDb & ";User ID=" & healthChklogin & ";Password=" & healthChkpw & ";"
	'當無法連接到檢查的SQL Server，將錯誤訊息記錄下來	
	If Err.Number <> 0 Then 
		'Wscript.Echo "Err.Number is " & Err.Number
		'Wscript.Echo "Err.Description is " & Err.Description
		'Wscript.Echo "Check SQL Server is " & healthChkServer
		ErrMsg = Err.Description
		
		On Error Resume Next
		Err.Clear 
		recSql = "INSERT INTO DBA.dbo.SpServerDiagnosticsResult(create_time,component_type,component_name,state_desc) VALUES (GETDATE(),N'Error',N'CollectError',N'" & ErrMsg & "')"
		'Wscript.Etho recSql
			
	Else
		healthSql = "EXEC sp_server_diagnostics;"
		Set healthRs = healthConn.EXECUTE(healthSql)
	
		WHILE NOT healthRs.EOF
		recSql = recSql & ",('" & DateTimeConvert(healthRs("create_time"),4,1) &_
								 "',N'" & healthRs("component_type") &_
								 "',N'" & healthRs("component_name") &_
								 "'," & healthRs("state") &_
								 ",N'" & healthRs("state_desc") &_
								 "','" & healthRs("data") &_
								 "')"
		healthRs.MoveNext
		WEND
	
		recSql = Mid(recSql, 2)
		recSql = "INSERT INTO DBA.dbo.SpServerDiagnosticsResult VALUES " & recSql & ";"

	End If 

	'Wscript.Echo recSql
	
	' Save data into Table
	recConn.EXECUTE(recSql)

	Set recConn = Nothing
	
	Set healthRs = Nothing
	Set healthConn = Nothing


Function DateTimeConvert(strdatetime,format_type,fill0)
	Dim YY, MM, DD, hh, mins, secs
	
	YY = Year(strdatetime)
	If fill0 = 1 then ' 要補0
		If LEN(Month(strdatetime)) < 2 Then MM = "0" & Month(strdatetime) Else MM = Month(strdatetime) End If
		If LEN(Day(strdatetime)) < 2 Then DD = "0" & Day(strdatetime) Else DD = Day(strdatetime) End If
		If LEN(Hour(strdatetime)) < 2 Then hh = "0" & Hour(strdatetime) Else hh = Hour(strdatetime) End If
		If LEN(Minute(strdatetime)) < 2 Then mins = "0" & Minute(strdatetime) Else mins = Minute(strdatetime) End If
		If LEN(Second(strdatetime)) < 2 Then secs = "0" & Second(strdatetime) Else secs = Second(strdatetime) End If
	ElseIf fill0 = 0 then ' 不補0
		MM = Month(strdatetime)
		DD = Day(strdatetime)
		hh = Hour(strdatetime)
		mins = Minute(strdatetime)
		secs = Second(strdatetime)
	End if

	Select Case format_type
		Case 1
			DateTimeConvert = YY & MM & DD
		Case 2
			DateTimeConvert = YY & MM & DD & hh & mins & secs
		Case 3
			DateTimeConvert = YY & "-" & MM & "-" & DD
		Case 4
			DateTimeConvert = YY & "-" & MM & "-" & DD & " " & hh & ":" & mins & ":" & secs
	End Select 

End Function