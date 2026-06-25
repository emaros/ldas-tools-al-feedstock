#!/bin/bash

mkdir -p _build
pushd _build

# Linux
if [[ "${target_platform}" == "linux"* ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DHAVE_PROCFS_PSINFO=0"
fi

# macOS
if [ "$(uname)" == "Darwin" ]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_ARCHITECTURES:STRING=${OSX_ARCH}"
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# configure
cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_CROSSCOMPILING_EMULATOR:STRING="${CMAKE_CROSSCOMPILING_EMULATOR}" \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=true \
  ${SRC_DIR} \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --parallel ${CPU_COUNT} --verbose
fi

cmake --build . --parallel ${CPU_COUNT} --verbose --target install
