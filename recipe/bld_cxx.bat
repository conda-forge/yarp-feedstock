mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DYARP_COMPILE_TESTS:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DYARP_COMPILE_BINDINGS:BOOL=OFF ^
    -DYARP_COMPILE_GUIS:BOOL=ON ^
    -DYARP_COMPILE_libYARP_math:BOOL=ON ^
    -DYARP_COMPILE_CARRIER_PLUGINS:BOOL=ON ^
    -DENABLE_yarpcar_bayer:BOOL=ON ^
    -DENABLE_yarpcar_tcpros:BOOL=ON ^
    -DENABLE_yarpcar_xmlrpc:BOOL=ON ^
    -DENABLE_yarpcar_priority:BOOL=ON ^
    -DENABLE_yarpcar_bayer:BOOL=ON ^
    -DENABLE_yarpcar_mjpeg:BOOL=ON ^
    -DENABLE_yarpcar_portmonitor:BOOL=ON ^
    -DENABLE_yarppm_bottle_compression_zlib:BOOL=ON ^
    -DENABLE_yarppm_depthimage_compression_zlib:BOOL=ON ^
    -DENABLE_yarppm_image_compression_ffmpeg:BOOL=ON ^
    -DENABLE_yarppm_depthimage_to_mono:BOOL=ON ^
    -DENABLE_yarppm_depthimage_to_rgb:BOOL=ON ^
    -DENABLE_yarpidl_thrift:BOOL=ON ^
    -DYARP_COMPILE_DEVICE_PLUGINS:BOOL=ON ^
    -DENABLE_yarpcar_human:BOOL=ON ^
    -DENABLE_yarpcar_rossrv:BOOL=ON ^
    -DENABLE_yarpmod_fakebot:BOOL=ON ^
    -DENABLE_yarpmod_imuBosch_BNO055:BOOL=ON ^
    -DENABLE_yarpmod_SDLJoypad:BOOL=ON ^
    -DENABLE_yarpmod_serialport:BOOL=ON ^
    -DENABLE_yarpmod_AudioPlayerWrapper:BOOL=ON ^
    -DENABLE_yarpmod_AudioRecorderWrapper:BOOL=ON ^
    -DENABLE_yarpmod_opencv_grabber:BOOL=ON ^
    -DENABLE_yarpmod_openCVGrabber:BOOL=ON ^
    -DENABLE_yarpmod_portaudio:BOOL=ON ^
    -DENABLE_yarpmod_portaudioPlayer:BOOL=ON ^
    -DENABLE_yarpmod_portaudioRecorder:BOOL=ON ^
    -DYARP_COMPILE_ALL_FAKE_DEVICES:BOOL=ON ^
    -DYARP_COMPILE_RobotTestingFramework_ADDONS:BOOL=ON ^
    -DYARP_USE_I2C:BOOL=OFF ^
    -DYARP_USE_JPEG:BOOL=ON ^
    -DYARP_USE_SDL:BOOL=ON ^
    -DYARP_USE_SQLite:BOOL=ON ^
    -DYARP_USE_SYSTEM_SQLite:BOOL=ON ^
    -DYARP_USE_SOXR:BOOL=ON ^
    -DENABLE_yarpmod_usbCamera:BOOL=OFF ^
    -DENABLE_yarpmod_usbCameraRaw:BOOL=OFF ^
    -DCREATE_PYTHON:BOOL=OFF ^
    -DYARP_DISABLE_VERSION_SOURCE:BOOL=ON ^
    -DCMAKE_DISABLE_FIND_PACKAGE_rerun_sdk:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

type CMakeCache.txt

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: Skip audio-related tests as they fail in the CI due to missing soundcard
:: Skip controlboardwrapper2_basic as it is flaky
:: Some tests are flaky
ctest --output-on-failure --repeat until-pass:5 -C Release -E "audio|controlboardwrapper2_basic|PeriodicThreadTest"
if errorlevel 1 exit 1

setlocal EnableDelayedExpansion
:: Generate and copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    multisheller %RECIPE_DIR%\%%F.msh --output .\%%F

    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.bash %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bash
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.ps1 %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.ps1
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.xsh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.xsh
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.zsh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.zsh
    if %errorlevel% neq 0 exit /b %errorlevel%
)
