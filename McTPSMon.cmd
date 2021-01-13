@echo off
setlocal

:: Load config
for /f %%a in (McTPSMon-config.ini) do set %%a

:: Get players
mcrcon -p %rconPassword% "list" > %tempFile%
for /f "tokens=3" %%i in (%tempFile%) do set count=%%i
if %count% equ 0 goto server_empty
for /f "tokens=2 delims=:" %%i in (%tempFile%) do set players=%%i
set players=%players:~1%
set players=%players:,=%

:: Get TPS
mcrcon -p %rconPassword% -s "debug start"
timeout /t %tpsMeasureSeconds% >nul
mcrcon -p %rconPassword% "debug stop" > %tempFile%
for /f "tokens=2 delims=(," %%i in (%tempFile%) do set tps=%%i

:: Get players locations
call :foreach getPlayerPos %players%

:: Output
call :output "%tps% [%count%:%playersstring%]"

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

goto cleanup

:foreach
if "%2"=="" goto :eof
call :%1 %2
shift /2
goto foreach

:getPlayerPos
set MCRCON_PASS=password
call GetPlayerPos.cmd %~1
set playersstring=%playersstring% %~1(%dim% %posx% %posy% %posz%)
goto :eof

:server_empty
echo Server empty
goto cleanup

:cleanup
forfiles /p %debugPath% /m profile-results-*.txt /d -%cleanupAgeDays% ^
  /c "cmd /c del @file" >nul 2>&1
del %tempFile%
goto :eof

:output
echo %~1
echo %date:~3,12% %time:~0,5% %~1>> %logFile%
goto :eof
