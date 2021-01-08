@echo off
setlocal

:: Config
set rconPassword=password
set debugPath=D:\CleanMcJava\debug
set debugCleanupDays=14
set tpsMeasureSeconds=5
set logFile=McTPSMon.log
set tempFile=output.tmp

:: Get players
mcrcon -p %rconPassword% "list" > %tempFile%
for /f "tokens=3" %%i in (%tempFile%) do set count=%%i
if %count% equ 0 goto end
for /f "tokens=2 delims=:" %%i in (%tempFile%) do set players=%%i

:: Get TPS
mcrcon -p %rconPassword% "debug start" > %tempFile%
timeout /t %tpsMeasureSeconds% >nul
mcrcon -p %rconPassword% "debug stop" > %tempFile%
for /f "tokens=2 delims=(," %%i in (%tempFile%) do set tps=%%i

:: Output to log
echo %date:~3,12% %time:~0,5% %tps% (%count%: %players:~1%)>> %logFile%

:: Cleanup
:end
forfiles /p %debugPath% /m profile-results-*.txt /d -%cleanupAgeDays% /c "cmd /c del @file" >nul 2>&1
del %tempFile%
