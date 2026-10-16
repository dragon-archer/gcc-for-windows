@echo off
setlocal
set "repository=%CD%\work\repository"
set /p "packages=" < "%repository%\packages.txt"
if errorlevel 1 exit /b 1
if not exist artifacts\logs mkdir artifacts\logs
taskkill /F /FI "MODULES eq cygwin1.dll" /IM *
start "" /b /wait "%CYGWIN_SETUP%" --quiet-mode --local-install --no-verify --root "%CYGWIN_ROOT%" --local-package-dir "%repository%" --site "file:///%repository:\=/%" --packages "%packages%" > artifacts\logs\setup.log 2>&1
set "status=%ERRORLEVEL%"
type artifacts\logs\setup.log
copy /Y "%CYGWIN_ROOT%\var\log\setup.log" artifacts\logs\setup-native.log > nul
copy /Y "%CYGWIN_ROOT%\var\log\setup.log.full" artifacts\logs\setup.log.full > nul
exit /b %status%
