@echo off
setlocal enableDelayedExpansion
set baseName=Anx1
set oDir=z:\Output\Env10\%baseName%
set modDir=..\Model

call gams makFig --simname=emiCap --BaUName=Comp --simType=CompStat --ifCal=0 --ifAppend=0 --BaseName=%baseName% --odir=%oDir% -idir=%modDir% -pw=140 -errmsg=1
