#!/bin/sh

cd ${SRC_DIR}/src/commands/yarpRerun

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_REQUIRE_FIND_PACKAGE_rerun_sdk:BOOL=ON

env
cat CMakeCache.txt 

cmake --build . --config Release
cmake --build . --config Release --target install
