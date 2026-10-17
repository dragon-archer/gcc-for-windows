#!/usr/bin/env bash
set -euo pipefail

repository=$(pwd)/work/repository
mkdir -p "${repository}/x86_64/release"
cp -R artifacts/packages/. "${repository}/x86_64/release/"
mksetupini --arch x86_64 --releasearea "${repository}" \
  --inifile "${repository}/x86_64/setup.ini" \
  --disable-check missing-depended-package \
  --disable-check missing-required-package \
  --disable-check missing-build-depended-package
packages=()
while IFS= read -r hint; do
  package=${hint%/*}
  package=${package##*/}
  packages+=("${package}")
done < <(find "${repository}/x86_64/release" -name '*.hint' ! -name '*-src.hint' ! -name '*-debuginfo-*.hint')
package_list=$(IFS=,; echo "${packages[*]}")
printf '%s\n' "${package_list}" > "${repository}/packages.txt"
setup_packages=()
for package in "${packages[@]}"; do
  case ${package} in
    gcc-*|*-gcc-*|libgccjit*|*-libgccjit*|libgnat*|*-libgnat*)
      setup_packages+=("${package}")
      ;;
  esac
done
printf '%s\n' "$(IFS=,; echo "${setup_packages[*]}")" > "${repository}/setup-packages.txt"
