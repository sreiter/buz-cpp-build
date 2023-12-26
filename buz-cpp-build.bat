@echo off

set "PATH=%PATH%;%~dp0"

set vcVarsScript="C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
if not exist %vcVarsScript% (
  set vcVarsScript="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

set curFolder=%CD%

set invalidParameters=0
if "%1" == "" set invalidParameters=1
if "%2" == "" set invalidParameters=1
if "%3" == "" set invalidParameters=1
if "%4" == "" set invalidParameters=1
if %invalidParameters% == 1 (
  echo   "Invalid parameters."
  echo   "1: Please specify the action you want to perform: edit, build, run, buildAndRun, cmakecache, buildfolder."
  echo   "2: The build type: Release or Debug."
  echo   "3: The root folder of the sources that shall be built."
  echo   "4: Please specify the build path."
  exit /b 1
)

set action=%1
set buildType=%2
set srcFolder=%3
set buildRootFolder=%4

for %%f in (%srcFolder%) do set projectName=%%~nxf

if not exist %buildRootFolder% (
  mkdir %buildRootFolder%
)
cd %buildRootFolder%

set build=0
set edit=0
set run=0
set runInVisualStudio=0
set runCMake=0
set openCmakeCache=0
set openBuildFolder=0

if "%action%" == "edit" (
  set edit=1
) else (
  if "%action%" == "run" (
    set run=1
  ) else (
    if "%action%" == "build" (
      set build=1
    ) else (
      if "%action%" == "buildAndRun" (
        set build=1
        set run=1
      ) else (
        if "%action%" == "buildAndRunVS" (
          set build=1
          set run=1
          set runInVisualStudio=1
        ) else (
          if "%action%" == "runcmake" (
              set runCMake=1
          )  else (
            if "%action%" == "cmakecache" (
              set openCmakeCache=1
            ) else (
              if "%action%" == "buildfolder" (
                set openBuildFolder=1
              )
            )
          )
        )
      )
    )
  )
)

set configFile=.%projectName%.buildconfig.bat
if not exist %configFile% (
  if exist .buildconfig.bat (
    echo "Initializing build configuration from `.buildconfig.bat`"
    copy .buildconfig.bat %configFile%
  ) else (
    echo "Initializing build configuration from scatch (no default `.buildconfig.bat` found)"

    echo rem Choose an executable which will be run for `build` and `buildAndRun` modes>> %configFile%
    echo set executable=>> %configFile%

    echo[>> %configFile%
    echo rem The path in which the given executable will be executed.>> %configFile%
    echo rem Either relative to the build directory or absolute.>> %configFile%
    echo set runInPath=>> %configFile%

    echo[>> %configFile%
    echo rem Command line arguments passed to the specified executable upon execution.>> %configFile%
    echo set arguments=>> %configFile%

    echo[>> %configFile%
    echo rem The path at which the root CMakeLists.txt is located. Relative to the source path.>> %configFile%
    echo set customCMakeListsLocation=>> %configFile%

    echo[>> %configFile%
    echo rem Additional CMake parameters.>> %configFile%
    echo set cmakeFlags=>> %configFile%
  )
)

if %edit% == 1 (
  echo "Edit build configuration"
  subl.exe %configFile%
  goto regularExit
)

rem Initialize config variables with default values. Actual values are set through `call %configFile%`.
set executable=""
set arguments=""
set runInPath=""
set customCMakeListsLocation=""
set cmakeFlags=""

call %configFile%

if "%customCMakeListsLocation%" == "" (
  set cmakeListsFolder=%srcFolder%
  set buildFolder=%projectName%-%buildType%
) else (
  set cmakeListsFolder=%customCMakeListsLocation%
  for %%f in (%cmakeListsFolder%) do set productName=%%~nxf
  set buildFolder=%projectName%-%productName%-%buildType%
)

if not exist %buildFolder% (
  mkdir %buildFolder%
)
cd %buildFolder%

if %openCmakeCache% == 1 (
  echo "Open CMakeCache.txt"
  subl.exe CMakeCache.txt
  goto regularExit
)

if %openBuildFolder% == 1 (
  echo "Open build folder"
  explorer.exe .
  goto regularExit
)

call %vcVarsScript%

set cmakeStartTime=%TIME%
if %build% == 1 (
  if not exist CMakeCache.txt (
    set runCMake=1
  ) else (
    if not exist build.ninja (
      set runCMake=1
    )
  )
)

if %runCMake% == 1 (
  echo cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=%buildType% %cmakeFlags% %cmakeListsFolder%
  cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=%buildType% %cmakeFlags% %cmakeListsFolder%
)

set ninjaStartTime=%TIME%
if %build% == 1 (
  ninja
)
 
set buildError=%ERRORLEVEL%

set endTime=%TIME%

set buildOrCMake = 0
if %build% == 1 set buildOrCMake=1
if %runCMake% == 1 set buildOrCMake=1

if %buildOrCMake% == 1 (
  echo cmake start time: %cmakeStartTime%
  echo ninja start time: %ninjaStartTime%
  echo end time:         %endTime%
  
  if exist compile_commands.json (
    copy compile_commands.json compile_commands.json.tmp
    move /Y compile_commands.json compile_commands.json.bak
    powershell -Command "(gc compile_commands.json.tmp) -replace 'C:\\\\bin\\\\clcache\\\\dist\\\\clcache\\\\clcache.exe', 'clang-cl.exe' | Out-File compile_commands.json.tmp"
    powershell -Command "(gc compile_commands.json.tmp) -replace ' /Yu"', ' /IGNORE"' | Out-File compile_commands.json.tmp"
    powershell -Command "(gc compile_commands.json.tmp) -replace ' /Fp"', ' /IGNORE"' | Out-File compile_commands.json.tmp"
    powershell -Command "(gc compile_commands.json.tmp) -replace ' /FI"', ' /IGNORE"' | Out-File compile_commands.json.tmp"
    powershell -Command "Get-Content compile_commands.json.tmp | Set-Content -Encoding utf8 compile_commands.json.translated"
    del compile_commands.json.tmp
    if exist compile_commands.json.translated (
      copy /Y compile_commands.json.translated %srcFolder%\compile_commands.json
    )
  )
)

if %buildError% neq 0 goto exitWithError

set launcher=
if %runInVisualStudio% == 1 (
  set "launcher=devenv.exe /Run"
)

if %run% == 1 (
  if "%executable%" == "" (
    echo No executable specified for `run` configuration.
    goto exitWithError
  ) else (
    if not "%runInPath%" == "" (
      if not exist "%runInPath%" (
        echo runInPath does not exist: %runInPath%
        goto exitWithError
      )
      cd %runInPath%
    )
    if not exist "%executable%" (
      echo executable does not exist: %executable%
      goto exitWithError
    )

    echo run: %launcher% %executable% %arguments%
    call %launcher% %executable% %arguments%
  )
)

:regularExit
echo [success: %buildFolder%]
cd %curFolder%
exit 0

:exitWithError
echo [FAILED: %buildFolder%]
cd %curFolder%
exit 1
