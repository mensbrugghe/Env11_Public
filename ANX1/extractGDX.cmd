@echo off
setlocal enableDelayedExpansion
set baseName=ANX1
set oDir=z:\Output\Env10\%baseName%

set ifError=0
call gams extractGDX --simName=BaU --BauName=BaU --simType=RcvDyn --ifCal=1 --baseName=%baseName% --odir=%oDir% -idir=..\NewModel -scrdir=%oDir% -ps=99999 -pw=150 -errmsg=1
echo.ErrorLevel = !errorlevel!
if %errorlevel% NEQ 0 (
   goto simError
)
goto endCMD

:simError
echo.extractGDX failed, check listing file
set ifError=1
goto endCMD

:endCMD
if %ifError%==0 (
   echo.Successful conclusion...
   exit /b 0
) else (
   echo.extractGDX failed...
   exit /b 1
)
