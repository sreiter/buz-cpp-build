# buz-cpp-build

Highly automated `Sublime Text` build scripts for the `C++` programming language on `Windows`,
using `CMake`, `ninja`, and `Visual Studio`. Some convenience tooling for the `Sublime LSP plugin`
is also provided.

Please clone this repository into your *SublimeText Packages* folder to get started.

# Requirements
- `CMake`
- `Visual Studio 2022`
- A writable folder `C:\build`

# Usage

## Building
Under `Tools -> Build System` choose one of
- buz-cpp-build-debug
- buz-cpp-build-release

Afterwards, `Tools -> Build With...` will offer the following build actions:
- The first entry forwards to `Edit Build Settings`.
- `Build`: Performs the build. If required, cmake will be invoked, first.
- `Build And Run`: Same as *Build*, but also runs the executable specified in the build settings.
- `Build And Run In Visual Studio`: Opens and runs the built executable in Visual Studio for debugging.
- `Edit Build Settings`: Opens a text file to customize the build. See [Edit Build Settings](#edit-build-settings).
- `Run CMake`: Runs *CMake* on the current project.
- `List Targets`: Lists all targets defined in cmake.
- `Open CMakeCache.txt`: Opens the *CMakeCache.txt* which contains the CMake build settings. 
- `Open Build Folder`: Opens the folder in which building is performd.

All of those actions generate a sub folder in the root build directory, matching the current project
folder, if no such folder exists.

## Edit Build Settings
This build action opens a file which is used to configure some aspects of the build:
```
rem Choose an executable which will be run for `build` and `buildAndRun` modes
set executable=

rem The path in which the given executable will be executed.
rem Either relative to the build directory or absolute.
set runInPath=

rem Command line arguments passed to the specified executable upon execution.
set arguments=

rem The path at which the root CMakeLists.txt is located. Relative to the source path.
set customCMakeListsLocation=

rem Additional CMake parameters.
set cmakeFlags=
```

- Arguments have to be specified right behind the `=` sign, without spaces in between.
- After the file was saved, its contents will be considered in the next build of the current project.
- Separate build settings exist for each project.
- If an argument contains spaces, the whole argument should be wrapped in `""`.
- If an `executable` is specified, it is also used as a ~target~ for `CMake`.
- A template for new build settings named `.buildconfig.bat` may optionally be stored in the root build folder.

# Sublime-LSP code model
A `compile_commands.json` file is generated during the build and copied into your source folder.
It can be used by the `Sublime-LSP` plugin with `clangd` for a complete code model in SublimeText.
