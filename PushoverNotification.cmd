@echo off

if "%PUSHOVER_APP_TOKEN%"=="" goto usage
if "%PUSHOVER_USER_KEY%"=="" goto usage

curl -s ^
  --form-string "token=%PUSHOVER_APP_TOKEN%" ^
  --form-string "user=%PUSHOVER_USER_KEY%" ^
  --form-string "message=%~1" ^
  https://api.pushover.net/1/messages.json
goto :eof

:usage
echo Usage: PushoverNotification.cmd "Message to send"
echo Required environment variables:
echo - PUSHOVER_APP_TOKEN
echo - PUSHOVER_USER_KEY
goto :eof
