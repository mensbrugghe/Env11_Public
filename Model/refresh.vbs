Set xl = CreateObject("Excel.Application")
On Error Resume Next
Set wb = xl.Workbooks.Open(WScript.Arguments(0) & WScript.Arguments(1) & ".xlsx")
If Err.Number <> 0 Then
   Wscript.Echo "Failed to find " & WScript.Arguments(0) & WScript.Arguments(1) & ".xlsx"
   WScript.Quit(1)
   Err.Clear
End If
Wscript.Echo "Refreshing " & WScript.Arguments(0) & WScript.Arguments(1) & ".xlsx"
wb.RefreshAll
On Error Resume Next
If Err.Number <> 0 Then
   Wscript.Echo "Failed to refresh " & WScript.Arguments(0) & WScript.Arguments(1) & ".xlsx"
   WScript.Quit(1)
   Err.Clear
End If
xl.DisplayAlerts=false
wb.Save
xl.DisplayAlerts=True
wb.Close True
xl.Quit
WScript.Quit(0)
