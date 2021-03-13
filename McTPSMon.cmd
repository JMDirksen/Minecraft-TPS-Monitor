@echo off

:: Load config
setlocal
for /f %%a in (config.ini) do set %%a

:: Date/Time vars
set yy=%date:~11,2%
set mm=%date:~6,2%
set dd=%date:~3,2%
set h=%time:~0,2%
set h=%h: =0%
set m=%time:~3,2%

:: Test rcon
mcrcon.exe -s list

:: Get performance%
for /f "tokens=4" %%i in ('mcrcon.exe "time query gametime"') do set gt1=%%i
timeout /t %ppMeasureSeconds% >nul
for /f "tokens=4" %%i in ('mcrcon.exe "time query gametime"') do set gt2=%%i
set /a ticks = %gt2% - %gt1%
set /a pp = %ticks% * 5 / %ppMeasureSeconds%
echo Performance%% %pp%

:: Get player count
for /f "tokens=3" %%i in ('mcrcon.exe list') do set count=%%i
(echo %yy%,%mm%,%dd%,%h%,%m%,%count%,%pp%)>> %UserCountDB%
if %count% equ 0 goto server_empty

:: Get players
for /f "tokens=2 delims=:" %%i in ('mcrcon.exe list') do set players=%%i
set players=%players:~1%
set players=%players:,=%

:: Get players locations
call :foreach getPlayerPos %players%

:: Output
call :output "%pp% [%count%:%playersstring%]"

:: Notify admin (in game)
if %pp% lss %notifyPpBelow% ^
  mcrcon.exe -s ^
  "tellraw %notifyAdmin% {\"text\":\"Performance% %pp%\",\"color\":\"red\"}"

:: Pushover notification
if %pp% lss %notifyPpBelow% ^
  call PushoverNotification.cmd "Performance%: %pp%"

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
goto :eof

:output
echo %~1
echo %date:~3,12% %time:~0,5% %~1>> %logFile%
goto :eof
