#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'This script is CI-only.' >&2; exit 1; }
[[ $(uname -s) == CYGWIN* ]] || { echo 'Cygwin is required.' >&2; exit 1; }
combination=${1:?combination is required}
case ${combination} in
  cygwin) recipe=gcc.cygport ;;
  cygwin-cross) recipe=mingw64-x86_64-gcc.cygport ;;
  *) exit 2 ;;
esac

repo_root=$(pwd)
source "${repo_root}/work/sources/${combination}.env"
shopt -s nullglob
common_patches=("${repo_root}"/patches/*.patch)
export GCC_PKGREL=${#common_patches[@]}
workspace_path=$(cygpath -m "${repo_root}")
build_dir=$(cygpath -u "${workspace_path%%/*}/gcc-build")
printf 'GFW_BUILD_ROOT=%s\n' "$(cygpath -m "${build_dir}")" >> "${GITHUB_ENV}"
echo "Building in ${build_dir}"
df -h / "${repo_root}"
mkdir -p "${build_dir}" "${repo_root}/artifacts/logs"
cp -R "${repo_root}/${combination}/." "${build_dir}/"
cp "${repo_root}/work/sources/${combination}.tar.xz" "${build_dir}/gcc-${GCC_PKGVER}.tar.xz"
cd "${build_dir}"
sed -i "s/^VERSION=.*/VERSION=\"${GCC_PKGVER}\"/" "${recipe}"
sed -i "s/^RELEASE=.*/RELEASE=\"${GCC_PKGREL}\"/" "${recipe}"
printf '\nSRC_URI="gcc-${PV}.tar.xz"\nSRC_DIR="gcc-${PV}"\n' >> "${recipe}"
cp "${recipe}" "${repo_root}/artifacts/logs/"
cp "${repo_root}/work/sources/${combination}.env" "${repo_root}/artifacts/logs/source.env"
cygport "${recipe}" prep compile install package
mkdir -p "${repo_root}/artifacts/packages"
for dist_dir in "${build_dir}/"*.x86_64/dist; do
  cp -R "${dist_dir}/." "${repo_root}/artifacts/packages/"
done
