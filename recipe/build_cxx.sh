#!/bin/sh

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]
then
  export YARP_COMPILING_ON_LINUX="ON"
else
  export YARP_COMPILING_ON_LINUX="OFF"
fi

# Set output of try_run, based on the value of this functions on amd64 builds
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DYARP_FLT_EXP_DIG:STRING=3 -DYARP_DBL_EXP_DIG:STRING=4 -DYARP_LDBL_EXP_DIG:STRING=5 -DYARP_FLOAT32_IS_IEC559:STRING=1 -DYARP_FLOAT64_IS_IEC559:STRING=1 -DYARP_FLOAT128_IS_IEC559:STRING=1"
fi

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DYARP_COMPILE_TESTS:BOOL=${YARP_COMPILING_ON_LINUX} \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DYARP_COMPILE_BINDINGS:BOOL=OFF \
    -DYARP_COMPILE_GUIS:BOOL=ON \
    -DYARP_COMPILE_libYARP_math:BOOL=ON \
    -DYARP_DISABLE_MACOS_BUNDLES:BOOL=ON \
    -DYARP_COMPILE_CARRIER_PLUGINS:BOOL=ON \
    -DENABLE_yarpcar_bayer:BOOL=ON \
    -DENABLE_yarpcar_tcpros:BOOL=ON \
    -DENABLE_yarpcar_xmlrpc:BOOL=ON \
    -DENABLE_yarpcar_priority:BOOL=ON \
    -DENABLE_yarpcar_bayer:BOOL=ON \
    -DENABLE_yarpcar_mjpeg:BOOL=ON \
    -DENABLE_yarpcar_portmonitor:BOOL=ON \
    -DENABLE_yarppm_bottle_compression_zlib:BOOL=ON \
    -DENABLE_yarppm_depthimage_compression_zlib:BOOL=ON \
    -DENABLE_yarppm_image_compression_ffmpeg:BOOL=ON \
    -DENABLE_yarppm_depthimage_to_mono:BOOL=ON \
    -DENABLE_yarppm_depthimage_to_rgb:BOOL=ON \
    -DENABLE_yarpidl_thrift:BOOL=ON \
    -DYARP_COMPILE_DEVICE_PLUGINS:BOOL=ON \
    -DENABLE_yarpcar_human:BOOL=ON \
    -DENABLE_yarpcar_rossrv:BOOL=ON \
    -DENABLE_yarpmod_fakebot:BOOL=ON \
    -DENABLE_yarpmod_imuBosch_BNO055:BOOL=ON \
    -DENABLE_yarpmod_SDLJoypad:BOOL=ON \
    -DENABLE_yarpmod_serialport:BOOL=ON \
    -DENABLE_yarpmod_AudioPlayerWrapper:BOOL=ON \
    -DENABLE_yarpmod_AudioRecorderWrapper:BOOL=ON \
    -DENABLE_yarpmod_opencv_grabber:BOOL=ON \
    -DENABLE_yarpmod_openCVGrabber:BOOL=ON \
    -DENABLE_yarpmod_portaudio:BOOL=ON \
    -DENABLE_yarpmod_portaudioPlayer:BOOL=ON \
    -DENABLE_yarpmod_portaudioRecorder:BOOL=ON \
    -DYARP_COMPILE_ALL_FAKE_DEVICES:BOOL=ON \
    -DYARP_COMPILE_RobotTestingFramework_ADDONS:BOOL=ON \
    -DYARP_USE_I2C:BOOL=${YARP_COMPILING_ON_LINUX} \
    -DYARP_USE_JPEG:BOOL=ON \
    -DYARP_USE_SDL:BOOL=ON \
    -DYARP_USE_SQLite:BOOL=ON \
    -DYARP_USE_SYSTEM_SQLite:BOOL=ON \
    -DYARP_USE_SOXR:BOOL=ON \
    -DENABLE_yarpmod_usbCamera:BOOL=${YARP_COMPILING_ON_LINUX} \
    -DENABLE_yarpmod_usbCameraRaw:BOOL=${YARP_COMPILING_ON_LINUX} \
    -DCREATE_PYTHON:BOOL=OFF \
    -DYARP_DISABLE_VERSION_SOURCE:BOOL=ON \
    -DCMAKE_DISABLE_FIND_PACKAGE_rerun_sdk:BOOL=ON

env
cat CMakeCache.txt

cmake --build . --config Release
cmake --build . --config Release --target install
# Skip audio-related tests as they fail in the CI due to missing soundcard
# Skip PeriodicThreadTest test as they fail for some unknown reason to be investigate
# Skip ControlBoardRemapperTest and FrameTransformClientTest as the tests are flaky
# Some tets are flaky
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --output-on-failure --repeat until-pass:5 -C Release -E "audio|PeriodicThreadTest|ControlBoardRemapperTest|FrameTransformClientTest|group_basic"
fi

# Generate and copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    multisheller ${RECIPE_DIR}/${CHANGE}.msh --output ./${CHANGE}
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${CHANGE}.bash" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.bash"
    cp "${CHANGE}.xsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.xsh"
    cp "${CHANGE}.zsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.zsh"
    cp "${CHANGE}.ps1" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.ps1"
done
