@echo off
rem Starts EaglerSPRelay from the folder this script lives in.
rem Any arguments are passed through, for example:  start.bat --debug
setlocal

cd /d "%~dp0"

where java >nul 2>&1
if errorlevel 1 (
	echo ERROR: java is not on your PATH, install a JRE 8 or newer
	pause
	exit /b 1
)

rem Switch the console to UTF-8 so the Chinese help text and config comments render instead of
rem turning into mojibake. The previous code page is restored after the relay exits.
for /f "tokens=2 delims=:" %%C in ('chcp') do set "OLDCP=%%C"
set "OLDCP=%OLDCP: =%"
chcp 65001 >nul

rem sun.stdout.encoding is what Java 8 reads, stdout.encoding is what Java 19+ reads; setting both
rem keeps the output UTF-8 on any of them and is harmless where it is not recognised.
java -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dstdout.encoding=UTF-8 -jar EaglerSPRelay.jar %*
set "RC=%ERRORLEVEL%"

if defined OLDCP chcp %OLDCP% >nul

rem keep the window open if the server died instead of shutting down cleanly
if not "%RC%"=="0" pause
exit /b %RC%
