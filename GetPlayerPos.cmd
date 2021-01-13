@echo off

if "%1"=="" goto missing_playername
if not exist mcrcon.exe goto mcrcon_missing
if "%MCRCON_PASS%"=="" goto missing_var
set dim=
set posx=
set posy=
set posz=

mcrcon.exe list

:getPlayerPos
for /f "tokens=7" %%a in ('mcrcon.exe "data get entity %1 Dimension"') do set dim=%%a
if "%dim%"=="" goto playernotfound
set dim=%dim:"=%
set dim=%dim:minecraft:=%
for /f "tokens=7,9,11 delims=[. " %%a in ('mcrcon.exe "data get entity %1 Pos"') do (
  set posx=%%a
  set posy=%%b
  set posz=%%c
)
echo %1:
echo dim = %dim%
echo posx = %posx%
echo posy = %posy%
echo posz = %posz%
goto :eof

:mcrcon_missing
echo The required executable mcrcon.exe is missing
goto :eof

:missing_var
echo Missing variable, please make sure the following variables are set:
echo required: MCRCON_PASS
echo optional: MCRCON_HOST (default: localhsot)
echo optional: MCRCON_PORT (default: 25575)
goto :eof

:missing_playername
echo Missing player name
echo Usage: GetPlayerPos.cmd ^<player name^>
goto :eof

:playernotfound
echo Player %1 not found
goto :eof
