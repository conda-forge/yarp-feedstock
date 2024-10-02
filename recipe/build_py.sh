#!/bin/sh

cd ${SRC_DIR}/bindings

rm -rf build
mkdir build
cd build

# Workaround for SP_DIR value that somestimes as of October 2024 seems wrong
Python_SP_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DYARP_COMPILE_BINDINGS:BOOL=ON \
    -DCREATE_PYTHON:BOOL=ON \
    -DYARP_PYTHON_PIP_METADATA_INSTALL:BOOL=ON \
    -DYARP_PYTHON_PIP_METADATA_INSTALLER=conda \
    -DYARP_DISABLE_VERSION_SOURCE:BOOL=ON \
    -DPython3_INCLUDE_DIR:PATH=$PREFIX/include/`ls $PREFIX/include | grep "python\|pypy"` \
    -DCMAKE_INSTALL_PYTHON3DIR:PATH=${Python_SP_DIR}

env
cat CMakeCache.txt 

cmake --build . --config Release
cmake --build . --config Release --target install
