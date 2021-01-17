@echo off

:: Load config
setlocal
for /f %%a in (config.ini) do set %%a

:: Date/Time vars
set yy=%date:~11,2%
set mm=%date:~6,2%
set dd=%date:~3,2%
set h=%time:~0,2%
set m=%time:~3,2%

:: Test rcon
mcrcon.exe -s list

:: Get player count
for /f "tokens=3" %%i in ('mcrcon.exe list') do set count=%%i
echo %yy%,%mm%,%dd%,%h%,%m%,%count% >> %UserCountDB%
if %count% equ 0 goto server_empty

:: Get players
for /f "tokens=2 delims=:" %%i in ('mcrcon.exe list') do set players=%%i
set players=%players:~1%
set players=%players:,=%

:: Get TPS
mcrcon.exe -s "debug start"
timeout /t %tpsMeasureSeconds% >nul
for /f "tokens=2 delims=(," %%i in ('mcrcon.exe "debug stop"') do set tps=%%i

:: Get players locations
call :foreach getPlayerPos %players%

:: Output
call :output "%tps% [%count%:%playersstring%]"

:: Notify admin (in game)
if %tps% lss %notifyTpsBelow% ^
  mcrcon.exe -s ^
  "tellraw %notifyAdmin% {\"text\":\"TPS %tps%\",\"color\":\"red\"}"

:: Pushover notification
if %tps% lss %notifyTpsBelow% ^
  call PushoverNotification.cmd "TPS: %tps%"

goto :eof

:foreach
if "%2"=="" goto :eof
call :%1 %2
shift /2
goto foreach

:getPlayerPos
call GetPlayerPos.cmd %~1
set playersstring=%playersstring% %~1(%dim%:%posx%,%posy%,%posz%)
goto :eof

:server_empty
echo Server empty
goto cleanup

:cleanup
forfiles /p %debugPath% /m profile-results-*.txt /d -%cleanupAgeDays% ^
  /c "cmd /c del @file" >nul 2>&1
goto :eof

:output
echo %~1
echo %date:~3,12% %time:~0,5% %~1>> %logFile%
goto :eof
