#!/bin/bash

action=$1
buildType=$2
srcFolder=$3
buildRootFolder=$4

projectName=$(basename $srcFolder)
buildFolder="$projectName-$buildType"
cmakeFlags=""
cmakeListsFolder=$srcFolder

runCMake=$(expr "$action" == "runcmake")

echo "action: $action"
echo "buildType: $buildType"
echo "srcFolder: $srcFolder"
echo "buildRootFolder: $buildRootFolder"
echo "projectName: $projectName"

if [ ! -d $buildRootFolder ]; then
  mkdir $buildRootFolder
fi

cd $buildRootFolder

echo "New path: " $(pwd)

echo $buildFolder

if [ ! -d $buildFolder ]; then
  mkdir $buildFolder
fi

cd $buildFolder
if [ "$runCMake" = "1" ] || [ ! -f ./CMakeCache.txt ]; then
  cmake -G"Ninja" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=$buildType $cmakeFlags $cmakeListsFolder
fi

cmake --build .
cp compile_commands.json $srcFolder/compile_commands.json