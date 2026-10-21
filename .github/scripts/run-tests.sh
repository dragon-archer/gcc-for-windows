#!/usr/bin/env bash
set -euo pipefail

combination=${1:?combination is required}
environment=${2:?environment is required}
repo_root=$(pwd)
test_root=${repo_root}/tests
work_root=${repo_root}/work/tests
mkdir -p "${work_root}"
mkdir -p artifacts/logs
exec > >(tee artifacts/logs/tests.log) 2>&1

case ${combination} in
  msys2|msys2-cross|mingw)
    set +u
    source /usr/share/makepkg/util.sh
    if [[ ${combination} == mingw ]]; then
      source_makepkg_config /etc/makepkg_mingw.conf
    else
      source_makepkg_config /etc/makepkg.conf
    fi
    set -u
    ;;
  cygwin|cygwin-cross)
    recipe=${work_root}/flags.cygport
    printf 'NAME=test-flags\nVERSION=1\nRELEASE=1\nSUMMARY="Test flags"\n' > "${recipe}"
    flags=$(cygport "${recipe}" vars CFLAGS CXXFLAGS)
    eval "$(printf '%s\n' "${flags}" | grep '^declare -x \(CFLAGS\|CXXFLAGS\)=')"
    ;;
esac

case ${combination}:${environment} in
  ubuntu:x86_64-linux-gnu) CC=gcc; CXX=g++ ;;
  msys2:*) CC=/usr/bin/gcc; CXX=/usr/bin/g++ ;;
  mingw:*) CC=${MINGW_PREFIX}/bin/gcc; CXX=${MINGW_PREFIX}/bin/g++ ;;
  msys2-cross:mingw32) CC=/opt/bin/i686-w64-mingw32-gcc; CXX=/opt/bin/i686-w64-mingw32-g++ ;;
  msys2-cross:mingw64) CC=/opt/bin/x86_64-w64-mingw32-gcc; CXX=/opt/bin/x86_64-w64-mingw32-g++ ;;
  msys2-cross:ucrt64) CC=/opt/bin/x86_64-w64-mingw32ucrt-gcc; CXX=/opt/bin/x86_64-w64-mingw32ucrt-g++ ;;
  cygwin:*) CC=/usr/bin/gcc; CXX=/usr/bin/g++ ;;
  cygwin-cross:*)
    CC=/usr/bin/x86_64-w64-mingw32-gcc
    CXX=/usr/bin/x86_64-w64-mingw32-g++
    export PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin:${PATH}
    ;;
  *) exit 2 ;;
esac
if [[ ${combination} == msys2-cross ]]; then
  source "${repo_root}/work/sources/${combination}.env"
  target=${CC##*/}
  target=${target%-gcc}
  export PATH=/opt/lib/gcc/${target}/${GCC_BASEVER}:${PATH}
fi
export CC CXX CFLAGS="${CFLAGS:-}" CXXFLAGS="${CXXFLAGS:-}"
export TEST_COMBINATION=${combination} TEST_ENVIRONMENT=${environment}
"${CC}" --version
"${CC}" -x c++ /dev/null -E -v

status=0
shopt -s nullglob
test_scripts=("${test_root}"/*/test*.sh)
set -f
for test_script in "${test_scripts[@]}"; do
  test_dir=${test_script%/*}
  test_name=${test_dir##*/}
  test_case=${test_script##*/}
  if [[ ${test_case} != test.sh ]]; then
    test_case=${test_case#test-}
    test_name+=/${test_case%.sh}
  fi
  (
    export TEST_DIR=${test_dir} OUTPUT=${work_root}/${test_name//\//-}.exe
    unset SOURCE
    source "${test_script}"
    if declare -F test_supported >/dev/null && ! test_supported; then
      SOURCE=${test_root}/00-sanity/skip.c
    fi
    : "${SOURCE:?test script must set SOURCE}"
    if declare -F compile_test >/dev/null; then
      compile_test
    else
      "${CC}" ${CFLAGS} "${SOURCE}" -o "${OUTPUT}"
    fi
    compile_status=$?
    if (( compile_status != 0 )); then
      printf 'FAIL %s: compilation returned %s\n' "${test_name}" "${compile_status}"
      exit 1
    fi
    "${OUTPUT}"
    run_status=$?
    case ${run_status} in
      0) printf 'PASS %s\n' "${test_name}" ;;
      77) printf 'SKIP %s\n' "${test_name}" ;;
      *) printf 'FAIL %s: program returned %s\n' "${test_name}" "${run_status}"; exit 1 ;;
    esac
  ) || status=1
done
exit "${status}"
