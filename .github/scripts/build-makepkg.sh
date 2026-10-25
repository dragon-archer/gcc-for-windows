#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'This script is CI-only.' >&2; exit 1; }
export GCC_COMBINATION=${1:?combination is required}
export GCC_ENVIRONMENT=${2:?environment is required}
repo_root=$(pwd)
combination_dir=${repo_root}/${GCC_COMBINATION}
source_artifacts=${repo_root}/work/sources
source "${source_artifacts}/${GCC_COMBINATION}.env"
export GCC_PKGVER GCC_BASEVER
shopt -s nullglob
common_patches=("${repo_root}"/patches/*.patch)
export GCC_PKGREL=${#common_patches[@]}

case ${GCC_COMBINATION}:${GCC_ENVIRONMENT} in
  msys2:msys|msys2-cross:mingw32|msys2-cross:mingw64|msys2-cross:ucrt64)
    makepkg_command=makepkg
    ;;
  mingw:mingw32|mingw:mingw64|mingw:ucrt64)
    makepkg_command=makepkg-mingw
    ;;
  *) echo 'Unsupported build combination/environment.' >&2; exit 1 ;;
esac

msys_root=$(cygpath -m /)
build_dir=$(cygpath -u "${msys_root%%/*}/gcc-build")
printf 'GFW_BUILD_ROOT=%s\n' "$(cygpath -m "${build_dir}")" >> "${GITHUB_ENV}"
echo "Building in ${build_dir}; MSYS2 root: ${msys_root}"
export PKGDEST=${repo_root}/artifacts/packages
export LOGDEST=${repo_root}/artifacts/logs
mkdir -p "${build_dir}" "${PKGDEST}" "${LOGDEST}"
cp -a "${combination_dir}/." "${build_dir}/"
cp "${repo_root}/.github/scripts/package-overrides.sh" "${build_dir}/ci-overrides.sh"
cp "${source_artifacts}/${GCC_COMBINATION}.env" "${LOGDEST}/source.env"
cd "${build_dir}"
printf '\nsource "${startdir}/ci-overrides.sh"\n' >> PKGBUILD
cp PKGBUILD ci-overrides.sh "${LOGDEST}/"
cp "${source_artifacts}/${GCC_COMBINATION}.tar.xz" "gcc-${GCC_PKGVER}.tar.xz"
"${makepkg_command}" -CfLrs --noconfirm
