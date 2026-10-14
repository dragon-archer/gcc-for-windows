#!/usr/bin/env bash
set -euo pipefail

source_dir=${1:?source directory is required}
patch_dir=${2:?patch directory is required}
patch_dir=$(cd "${patch_dir}" && pwd)
export LC_ALL=C

shopt -s nullglob
patches=("${patch_dir}"/*.patch)

cd "${source_dir}"
if (( ${#patches[@]} == 0 )); then
  echo "No common patches to apply."
  exit 0
fi

for patch_file in "${patches[@]}"; do
  echo "Applying common patch: ${patch_file}"
  patch -Np1 -i "${patch_file}"
done
