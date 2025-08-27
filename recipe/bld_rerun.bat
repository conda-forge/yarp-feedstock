cd src\commands\yarpRerun
rmdir /s /q build
mkdir build
cd build

cmake %CMAKE_ARGS% -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_REQUIRE_FIND_PACKAGE_rerun_sdk:BOOL=ON ^
    ..
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
