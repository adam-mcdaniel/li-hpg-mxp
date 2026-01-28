#!/bin/bash

export SETUP_BUILD_ENV=$(pwd)/../setup-build-env.sh
setup_build_environment() {
    if [ -f $SETUP_BUILD_ENV ]; then
        source $SETUP_BUILD_ENV
    else
        export ROCM_VERSION=6.4.1
        module load libfabric/1.22.0 perftools-base/24.11.0 PrgEnv-amd/8.6.0 cray-mpich/8.1.31 amd/$ROCM_VERSION rocm/$ROCM_VERSION
        export MPICH_GPU_SUPPORT_ENABLED=1
        export CRAY_MPICH_PREFIX=$(dirname $(dirname $(which mpicc)))
    fi
}
setup_build_environment


rm -rf build CMakeCache.txt CMakeFiles

export HPG_ROOT=$(pwd)
export PREFIX=$HPG_ROOT/install

rm -rf build
mkdir build
cd build

echo "ROCM_PATH: $ROCM_PATH"
echo "CRAY_MPICH_PREFIX: $CRAY_MPICH_PREFIX"
echo "PREFIX: $PREFIX"


export HIP_PATH=${ROCM_PATH}
cmake \
    -DHPGMP_ENABLE_HIP=ON \
    -DHPGMP_WITH_HIP=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_HIP_ARCHITECTURES=gfx90a \
    -DCMAKE_C_STANDARD=99 \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_HIP_COMPILER_LAUNCHER=$(which hipcc) \
    -DCMAKE_HIP_FLAGS="-I$CRAY_MPICH_PREFIX/include" \
    -DCMAKE_CXX_FLAGS="-I$CRAY_MPICH_PREFIX/include" \
    -DCMAKE_EXE_LINKER_FLAGS="-L$CRAY_MPICH_PREFIX/lib -g -std=c++11 -lmpi_gtl_hsa" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L$CRAY_MPICH_PREFIX/lib -g -std=c++11 -lmpi_gtl_hsa" \
    -DCMAKE_CXX_COMPILER=$(which hipcc) \
    -DCMAKE_C_COMPILER=$(which hipcc) \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DROCM_PATH=${ROCM_PATH} \
    -DROCBLAS_PATH=${ROCM_PATH} \
    -DROCSOLVER_PATH=${ROCM_PATH} \
    ..

make VERBOSE=1 -j 32 install