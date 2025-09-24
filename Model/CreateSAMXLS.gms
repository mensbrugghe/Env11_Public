if(%ifAggTrade%,
   skip(r) = yes ;
else
   skip("trd") = yes ;
) ;

set fields /
   Time
   Qual
   Region
   Sim
   Var
   rlab
   clab
   Value
/ ;

set targets /
   %timeTgt%
   %regTgt%
   %simTgt%
   %varTgt%
/ ;

set mapTgt(fields,targets) /
   Time.%timeTgt%
   region.%regTgt%
   sim.%simTgt%
   var.%varTgt%
/ ;

Table PivotOptions(fields, *)
         Pos    ifSum
Time       3      0
Qual       3      0
Region     3      0
Sim        3      0
Var        3      0
rlab       1      1
clab       2      1
Value      4      1
;

scalar order / 0 / ;

file script / %fileName%.vbs / ;
put script ;

*  Script pre-amble

Put 'Wscript.Echo "Creating Excel worksheet pivot table(s)...."' / ;
Put 'Wscript.Echo "This will take a minute..."' / ;
Put 'Wscript.Echo ""' / ;
Put 'Set xl = CreateObject("Excel.Application")' / ;
Put 'xl.DisplayAlerts=False' / ;
Put 'Set wb = xl.Workbooks.Add' / ;

*  Put 'Wscript.Echo "Creating pivot table number",', itab:2:0 / ;
Put 'Set pc = wb.PivotCaches.Create(2)' / ;
Put 'pc.Connection = "ODBC;DSN=Text Files;DefaultDir=Z:\Output\Env10\%BaseName%;DriverId=27;FIL=text;MaxBufferSize=2048;PageTimeout=5;Dbq=%inDir%\"' / ;
Put 'pc.CommandText = "select * from [%fileName%.csv] WHERE (Var=', "'sam'", ')"' / ;

*  Add a wks
Put 'If wb.Sheets.count = 0 Then' / ;
Put '   Set sh = wb.Sheets.Add()' / ;
Put 'Else' / ;
Put '   Set sh = wb.Sheets(1)' / ;
Put 'End If' / ;
Put 'sh.Name="SAM"' / ;

*  Create the pivot table

Put 'Set pt = pc.CreatePivotTable(sh.Range("A1"))' / ;
Put 'pt.SmallGrid = False' / ;
Put 'pt.HasAutoFormat = False' / ;
Put 'pt.PivotCache.RefreshPeriod = 0' / ;

loop(fields,
   put 'pt.PivotFields("',fields.tl:0:0,'").Orientation=',PivotOptions(fields,"Pos"):0:0 / ;
) ;

loop(fields$(PivotOptions(fields,"ifSum")=0),
   put 'pt.PivotFields("',fields.tl:0:0,
            '").Subtotals = Array(False, False, False, False, False, False, False, False, False, False, False, False)' / ;
) ;

Put 'pt.PivotFields("Sum of Value").NumberFormat = "%format%"' / ;

*  Sort the labels

*  Regions

order=0 ;
loop(mapOrder(sortOrder,r),
   order = order+1 ;
   Put 'pt.PivotFields("Region").PivotItems("', r.tl:0:0, '").Position = ', order:0:0 / ;
) ;

*  Row labels
order=0 ;
loop(mapOrder(sortOrder,is)$(not skip(is)),
   order = order+1 ;
   Put 'pt.PivotFields("rlab").PivotItems("', is.tl:0:0, '").Position = ', order:0:0 / ;
) ;

*  Column labels
order=0 ;
loop(mapOrder(sortOrder,is)$(not skip(is)),
   order = order+1 ;
   Put 'pt.PivotFields("clab").PivotItems("', is.tl:0:0, '").Position = ', order:0:0 / ;
) ;

loop(mapTgt(fields,targets),
   Put 'pt.PivotFields("',fields.tl:0:0,'").CurrentPage = "',targets.tl:0:0,'"' / ;
) ;

*  Finish formatting the pivot table and the wks

Put 'pt.ColumnGrand = True' / ;
Put 'pt.RowGrand = True' / ;
Put 'pt.TableStyle2 = "PivotStyleMedium7"' / ;
Put 'sh.Columns("A:A").EntireColumn.AutoFit' / ;
put / ;

*  Finish the script

Put 'Wscript.Echo "Saving %fileName%.xlsx"' / ;
Put 'wb.SaveAs("%wDir%%fileName%.xlsx")' / ;
Put 'wb.Close' / ;
Put 'xl.Quit' / ;

putclose script ;

*  Execute the script creating the Excel file


$iftheni exist "%wDir%%fileName%.xlsx"
*  Refresh
   execute "cscript %idir%\refresh.vbs %wDir% %fileName%"
$else
   execute "cscript %fileName%.vbs //Nologo" ;
$endif
