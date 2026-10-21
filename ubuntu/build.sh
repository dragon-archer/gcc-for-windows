#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'This script is CI-only.' >&2; exit 1; }
mkdir -p work/source-ubuntu work/build-ubuntu artifacts/logs
exec > >(tee artifacts/logs/build.log) 2>&1

cp work/sources/ubuntu.env artifacts/logs/source.env
tar -xf work/sources/ubuntu.tar.xz --strip-components=1 -C work/source-ubuntu
cd work/build-ubuntu
../source-ubuntu/configure --build=x86_64-linux-gnu --enable-languages=c,c++
make -j"$(nproc)"
sudo make install
sudo ldconfig /usr/local/lib64
