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
if [[ ${1:-} == prepare ]]; then
  exit 0
fi
mkdir -p artifacts/logs
"$(cygpath -u "${CYGWIN_SETUP}")" \
  --quiet-mode --local-install --no-verify --upgrade-also \
  --root "${CYGWIN_ROOT}" --local-package-dir "$(cygpath -w "${repository}")" \
  --site "file:///$(cygpath -m "${repository}")" --packages "${package_list}" \
  2>&1 | tee artifacts/logs/setup.log
