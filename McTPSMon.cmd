@echo off
setlocal
mcrcon -p password "list" > output.tmp
for /f "tokens=3" %%i in (output.tmp) do set count=%%i
if %count% equ 0 exit /b
for /f "tokens=2 delims=:" %%i in (output.tmp) do set players=%%i
mcrcon -p password "debug start" > output.tmp
timeout /t 5 >nul
mcrcon -p password "debug stop" > output.tmp
for /f "tokens=2 delims=(," %%i in (output.tmp) do set tps=%%i
echo %date:~3,12% %time:~0,5% %tps% (%count%: %players:~1%)>> McTPSMon.log
del output.tmp
