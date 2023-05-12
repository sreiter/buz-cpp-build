@echo off

set vcVarsScript="C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
if not exist %vcVarsScript% (
  set vcVarsScript="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

set invalidParameters=0
if "%1" == "" set invalidParameters=1
if "%2" == "" set invalidParameters=1
if %invalidParameters% == 1 (
  echo   "Invalid parameters."
  echo   "1: Please specify the action you want to perform: build, run, buildAndRun."
  echo   "2: The file that you want to build."
  exit /b 1
)

set action=%1
set filename=%2

set build=0
set run=0

if "%action%" == "run" (
  set run=1
) else (
  if "%action%" == "build" (
    set build=1
  ) else (
    if "%action%" == "buildAndRun" (
      set build=1
      set run=1
    )
  )
)

call %vcVarsScript%

if %build% == 1 (
  cl.exe "%filename%" /std:c++17 /W4 /WX /EHsc /Fe: buz-out.exe
  if %ERRORLEVEL% neq 0 goto exitWithError
)

if %run% == 1 (
  buz-out.exe
)

:regularExit
echo [success: %buildFolder%]
cd %curFolder%
exit 0

:exitWithError
echo [FAILED: %buildFolder%]
cd %curFolder%
exit 1
