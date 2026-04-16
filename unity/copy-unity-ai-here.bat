@echo off
setlocal enableextensions

REM Copy Unity .cursor config from this repo into a target project folder.
REM Usage:
REM   copy-unity-ai-here.bat [TARGET_PROJECT_PATH]
REM Examples:
REM   copy-unity-ai-here.bat
REM   copy-unity-ai-here.bat "E:\Projects\Unity\my-game"

REM Explicit source folder (so script still works even if you copy it elsewhere).
set "SOURCE=E:\Projects\Tools\aiskills\unity\.cursor"
set "TARGET_ROOT=%~1"

if "%TARGET_ROOT%"=="" (
  set "TARGET_ROOT=%cd%"
)

set "TARGET=%TARGET_ROOT%\.cursor"

if not exist "%SOURCE%\" (
  echo [ERROR] Source .cursor folder not found:
  echo         %SOURCE%
  exit /b 1
)

if /I "%SOURCE%"=="%TARGET%" (
  echo [ERROR] Source and target are the same folder.
  echo         Run this script from a different target directory
  echo         or pass a target path argument.
  exit /b 1
)

if not exist "%TARGET%\" (
  mkdir "%TARGET%"
)

echo Copying Unity .cursor config...
echo Source: %SOURCE%
echo Target: %TARGET%

xcopy "%SOURCE%\*" "%TARGET%\" /E /I /Y >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy .cursor contents.
  exit /b 1
)

echo [OK] .cursor copied successfully.
echo      %TARGET%
exit /b 0
