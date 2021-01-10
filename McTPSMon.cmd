@echo off
setlocal

:: Load config
for /f %%a in (McTPSMon-config.ini) do set %%a

:: Get players
mcrcon -p %rconPassword% "list" > %tempFile%
for /f "tokens=3" %%i in (%tempFile%) do set count=%%i
if %count% equ 0 goto end
for /f "tokens=2 delims=:" %%i in (%tempFile%) do set players=%%i

:: Get TPS
mcrcon -p %rconPassword% -s "debug start"
timeout /t %tpsMeasureSeconds% >nul
mcrcon -p %rconPassword% "debug stop" > %tempFile%
for /f "tokens=2 delims=(," %%i in (%tempFile%) do set tps=%%i

:: Output to console/log
echo %date:~3,12% %time:~0,5% %tps% (%count%: %players:~1%)
echo %date:~3,12% %time:~0,5% %tps% (%count%: %players:~1%)>> %logFile%

:: Notify admin (in game)
if %tps% lss %notifyTpsBelow% ^
  mcrcon -p %rconPassword% -s ^
  "tellraw %notifyAdmin% {\"text\":\"TPS %tps%\",\"color\":\"red\"}"

:: Pushover notification
if %tps% lss %notifyTpsBelow% ^
  curl -s ^
  --form-string "token=%pushoverAppToken%" ^
  --form-string "user=%pushoverUserKey%" ^
  --form-string "message=TPS: %tps%" ^
  https://api.pushover.net/1/messages.json >nul

:: Cleanup
:end
forfiles /p %debugPath% /m profile-results-*.txt /d -%cleanupAgeDays% ^
  /c "cmd /c del @file" >nul 2>&1
del %tempFile%
