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
"$(cygpath -u "${CYGWIN_SETUP}")" --quiet-mode --local-install --no-verify \
  --root "$(cygpath -w /)" --local-package-dir "$(cygpath -w "${repository}")" \
  --site "file:///$(cygpath -m "${repository}")" --packages "${package_list}" | tee artifacts/logs/setup.log
