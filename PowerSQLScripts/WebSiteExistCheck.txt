'----------------------------------------------------------------------------------------------------------------------------  
'Script Name : WebSiteExistCheck.vbs     
'Author      : Brad Chen    
'Created     : 2020-09-14
'Description : This script check the status code of a URL.  
'----------------------------------------------------------------------------------------------------------------------------  



' Table Schema
'USE [DBA]
'GO
'SET ANSI_NULLS ON
'GO
'SET QUOTED_IDENTIFIER ON
'GO
'CREATE TABLE [dbo].[ServerProbe](
'	[Sn] [int] IDENTITY(1,1) NOT NULL,
'	[TargetUrl] [nvarchar](100) NULL,
'	[ResponseStatus] [int] NULL,
'	[ResponseTime] [int] NULL,
'	[ProbeTime] [datetime] NULL,
' CONSTRAINT [PK_ServerProbe] PRIMARY KEY CLUSTERED 
'(
'	[Sn] ASC
')WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FG1]
') ON [FG1]
'GO




'Initialization  Section     
'----------------------------------------------------------------------------------------------------------------------------  
Option Explicit  
Dim objFSO, scriptBaseName, strPath
Dim strTargetUrl, strTargetUrl2
Dim urlStatus, respTime

strTargetUrl = "https://www.google.com/test"
strTargetUrl2 = "https://www.google.com"

'----------------------------------------------------------------------------------------------------------------------------  
'Main Processing Section  
'----------------------------------------------------------------------------------------------------------------------------  
On Error Resume Next 
   Set objFSO     = CreateObject("Scripting.FileSystemObject")  
   scriptBaseName = objFSO.GetBaseName(Wscript.ScriptFullName)  
   strPath = objFSO.GetParentFolderName(Wscript.ScriptFullName)

   ProcessScript strTargetUrl
   ProcessScript strTargetUrl2

   'Wscript.Echo "a test message line"
   Wscript.Echo "Err.Number is " & Err.Number
   
   If Err.Number <> 0 Then 
      Wscript.Quit  
   End If 
On Error Goto 0  
'----------------------------------------------------------------------------------------------------------------------------  
'Name       : ProcessScript -> Primary Function that controls all other script processing.     
'Parameters : None          ->      
'Return     : None          ->      
'----------------------------------------------------------------------------------------------------------------------------  
Function ProcessScript(url)
   If Not EnumerateURLStatus(url, urlStatus) Then 
      Exit Function 
   End If 

   'Select Case urlStatus   
      'Case "404" 
      '   Wscript.Echo "The status of the URL " & url & " is " & urlStatus, vbCritical, scriptBaseName  

      'Case Else 
         'Wscript.Echo "The status of the URL " & url & " is " & urlStatus, vbInformation, scriptBaseName  
		 'Wscript.Echo "before write db1"
		 'Wscript.Echo respTime
         WriteIntoDb url, urlStatus, respTime

   'End Select 
End Function 
'----------------------------------------------------------------------------------------------------------------------------  
'Name       : EnumerateURLStatus -> Enumerates the status code of a URL.    
'Parameters : url                -> Input/Output : String containing the URL of the web page to enumerate.  
'           : urlStatus          -> Input/Output : Integer containing the url status code number.  
'Return     : EnumerateURLStatus -> Returns True and the status code of the URL otherwise returns False.  
'----------------------------------------------------------------------------------------------------------------------------  
Function EnumerateURLStatus(url, urlStatus)  
   Dim objXML  
   EnumerateURLStatus = False 
   On Error Resume Next 
      Set objXML = CreateObject("MSXML2.XMLHTTP.3.0")  
      If Err.Number <> 0 Then 
         Exit Function 
      End If 
	  'Wscript.Echo "xxx"
	  Dim t,t2
      t = Timer
	
      objXML.open "GET", url, False 
      objXML.send  
	  'Wscript.Echo "xxx"
	  t2 = Timer

	  'Wscript.Echo cstr(Cint((t2-t)* 1000)) & "ms"
      respTime = Cint((t2-t)* 1000)
	  'Wscript.Echo cstr(Cint((t2-t)* 1000)) & "ms"
	  
      urlStatus = CInt(objXML.Status)  
      If Err.Number <> 0 Then 
         Exit Function 
      End If 
   On Error Goto 0  
   EnumerateURLStatus = True 
End Function 


' MDAC 的 ODBC
'Conn.Open "Driver={SQL SERVER};server=" & Serverhost & ";uid=" & uid & ";pwd=" & pwd & ";database=" & dbName

' MDAC 的 OLD DB
'Conn.Open "Provider=SQLOLEDB; Data Source=" & ServerHost & "; Initial Catalog=" & DBName & ";Integrated Security=SSPI;"

' SQL Native Client OLE DB
'Conn.ConnectionString = "Provider=SQLNCLI;" _
'         & "Server=(local);" _
'         & "Database=META;" _ 
'         & "Integrated Security=SSPI;" _
'         & "DataTypeCompatibility=80;" _
'         & "MARS Connection=True;"
'	
'	";Uid=" & uid & _
'	";Pwd=" & pwd & ";"
'
Sub WriteIntoDb(vUrl, vUrlStatus, respTime)
	Dim Conn, rs, sql
	Set Conn = CreateObject("ADODB.Connection")
	Conn.ConnectionString = "Provider=SQLNCLI11;" _
			 & "Server=(local);" _
			 & "Database=DBA;" _ 
			 & "Integrated Security=SSPI;" _
			 & "DataTypeCompatibility=80;" _
			 & "MARS Connection=True;"
	'Conn.Open "Provider=SQLOLEDB; Data Source=(local); Initial Catalog=DBA;Integrated Security=SSPI;"
	Conn.Open
	
	'Wscript.Echo "before write db"
	
	sql = "INSERT INTO ServerProbe(TargetUrl,ResponseStatus,ResponseTime,ProbeTime) VALUES('" & vUrl & "'," & Cstr(vUrlStatus) & "," & Cstr(respTime) & ",'" & DateTimeConvert(NOW,4,1) & "')"
	'Wscript.Echo sql
	Set rs = Conn.EXECUTE(sql)

	Set rs = Nothing
	Set Conn = Nothing
End Sub


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