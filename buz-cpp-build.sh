#!/bin/bash

echo "CXX compiler: $CXX"

action=$1
srcFolder=$2
buildRootFolder=$3

rootPath=$(pwd)
projectName=$(basename $srcFolder)
configFile=".$projectName.buildconfig"
cmakeFlags=""
cmakeListsFolder=$srcFolder

# runCMake=$(expr "$action" == "runcmake")
runEdit=0
runCMake=0
runBuild=0
runExecutable=0
listTargets=0
openCMakeCache=0

if [ "$action" == "edit" ]; then
  runEdit=1
fi

if [ "$action" == "runcmake" ]; then
  runCMake=1
fi

if [ "$action" == "build" ]; then
  runBuild=1
fi

if [ "$action" == "buildAndRun" ]; then
  runBuild=1
  runExecutable=1
fi

if [ "$action" == "listTargets" ]; then
  listTargets=1
fi

if [ "$action" == "cmakecache" ]; then
  openCMakeCache=1
fi

echo "action: $action"
echo "buildType: $buildType"
echo "srcFolder: $srcFolder"
echo "buildRootFolder: $buildRootFolder"
echo "projectName: $projectName"
echo "configFile: $configFile"

if [ ! -d $buildRootFolder ]; then
  mkdir $buildRootFolder
fi

cd $buildRootFolder

echo "New path: " $(pwd)

if [ ! -f $configFile ]; then
  echo "Initializing build configuration"

  echo "# Specify the build type. Debug, Release" >> $configFile
  echo "buildType=Release" >> $configFile
  echo "" >> $configFile

  echo "# Choose an executable which will be run for `build` and `buildAndRun` modes" >> $configFile
  echo "executable=" >> $configFile
  echo "" >> $configFile

  echo "# The path in which the given executable will be executed." >> $configFile
  echo "# Either relative to the build directory or absolute." >> $configFile
  echo "runInPath=" >> $configFile
  echo "" >> $configFile

  echo "# Command line arguments passed to the specified executable upon execution." >> $configFile
  echo "arguments=" >> $configFile
  echo "" >> $configFile

  echo "# The path at which the root CMakeLists.txt is located. Relative to the source path." >> $configFile
  echo "customCMakeListsLocation=" >> $configFile
  echo "" >> $configFile

  echo "# Additional CMake parameters." >> $configFile
  echo "cmakeFlags=" >> $configFile
fi

if [ "$runEdit" == 1 ]; then
  subl $configFile
  cd "$rootPath"
  exit 0
fi

source $configFile

echo "executable: $executable"
echo "buildType: $buildType"
echo "runInPath: $runInPath"
echo "arguments: $arguments"
echo "customCMakeListsLocation: $customCMakeListsLocation"
echo "cmakeFlags: $cmakeFlags"

buildFolder="$projectName-$buildType"
echo "buildFolder: $buildFolder"

if [ ! -d $buildFolder ]; then
  mkdir $buildFolder
fi
cd $buildFolder

if [ "$runCMake" == 1 ] || [ ! -f ./CMakeCache.txt ]; then
  cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=$buildType $cmakeFlags $cmakeListsFolder
fi

if [ "$listTargets" == 1 ]; then
  cmake --build . --target help
  cd "$rootPath"
  exit 0
fi

if [ "$openCMakeCache" == 1 ]; then
  subl CMakeCache.txt
  cd "$rootPath"
  exit 0
fi

buildError=0
if [ "$runBuild" == 1 ]; then
  cmake --build .
  buildError=$?
fi

if [ "$buildError" == 1 ]; then
  cd "$rootPath"
  exit 1
fi

if [ "$runExecutable" == 1 ]; then
  cd $runInPath
  eval "./$executable"
  out=$?
  cd "$rootPath"
  exit $out
fi

cp compile_commands.json $srcFolder/compile_commands.json
cd "$rootPath"

