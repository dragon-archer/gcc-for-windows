#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'This script is CI-only.' >&2; exit 1; }
mkdir -p work/build artifacts/logs
exec > >(tee artifacts/logs/build.log) 2>&1

source work/sources/ubuntu.env
cp work/sources/ubuntu.env artifacts/logs/source.env
tar -xf work/sources/ubuntu.tar.xz -C work
cd work/build
../gcc-${GCC_PKGVER}/configure --build=x86_64-linux-gnu --enable-languages=c,c++
make -j"$(($(nproc)+1))" -O STAGE1_CFLAGS="-O2"
sudo make install
sudo ldconfig /usr/local/lib64
