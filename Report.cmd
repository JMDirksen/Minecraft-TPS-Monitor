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

:: Day average
set sum=0
set count=0
for /f "tokens=1,2,3,4,5,6 delims=," %%a in (%UserCountDB%) do (
  if %%a equ %yy% if %%b equ %mm% if %%c equ %dd% (
    set /a sum+=%%f
	set /a count+=1
  )
)
set /a avg=%sum% / %count%
set /a dec=%sum% * 100 / %count%
set dec=%dec:~-2%
set dayavg=%avg%.%dec%

:: Month average
set sum=0
set count=0
for /f "tokens=1,2,3,4,5,6 delims=," %%a in (%UserCountDB%) do (
  if %%a equ %yy% if %%b equ %mm% (
    set /a sum+=%%f
	set /a count+=1
  )
)
set /a avg=%sum% / %count%
set /a dec=%sum% * 100 / %count%
set dec=%dec:~-2%
set monthavg=%avg%.%dec%

:: Year average
set sum=0
set count=0
for /f "tokens=1,2,3,4,5,6 delims=," %%a in (%UserCountDB%) do (
  if %%a equ %yy% (
    set /a sum+=%%f
	set /a count+=1
  )
)
set /a avg=%sum% / %count%
set /a dec=%sum% * 100 / %count%
set dec=%dec:~-2%
set yearavg=%avg%.%dec%

:: Results
echo Updated:       %dd%-%mm%-%yy% %h%:%m% > %Report%
echo Day average:   %dayavg% >> %Report%
echo Month average: %monthavg% >> %Report%
echo Year average:  %yearavg% >> %Report%

type %Report%
pause
