#!/usr/bin/env bash
set -euo pipefail

[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'This script is CI-only.' >&2; exit 1; }
mode=${1:?download or prepare is required}
repo_root=$(pwd)
cache_dir=${repo_root}/work/downloads
output_dir=${repo_root}/work/sources
combinations=(msys2 msys2-cross mingw)
mkdir -p "${cache_dir}" "${output_dir}"
declare -A prepared=()

for combination in "${combinations[@]}"; do
  read -r ref < "${combination}/gcc-ref"
  if [[ ${ref} =~ ^[0-9]+-[0-9]{8}$ ]]; then
    archive=gcc-${ref}.tar.xz
    url=https://gcc.gnu.org/pub/gcc/snapshots/${ref}/${archive}
  elif [[ ${ref} == git:* ]]; then
    revision=${ref#git:}
    archive=gcc-git-${revision//\//_}.tar.gz
    url=https://github.com/gcc-mirror/gcc/archive/${revision}.tar.gz
  else
    echo "Unsupported GCC ref: ${ref}" >&2
    exit 1
  fi

  case ${mode} in
    download)
      if [[ ! -f ${cache_dir}/${archive} ]]; then
        curl --fail --location --retry 3 "${url}" -o "${cache_dir}/${archive}.part"
        mv "${cache_dir}/${archive}.part" "${cache_dir}/${archive}"
      fi
      ;;
    prepare)
      if [[ -n ${prepared[${ref}]:-} ]]; then
        cp "${output_dir}/${prepared[${ref}]}.tar.xz" "${output_dir}/${combination}.tar.xz"
        cp "${output_dir}/${prepared[${ref}]}.env" "${output_dir}/${combination}.env"
        continue
      fi
      source_dir=${repo_root}/work/source-${combination}
      mkdir -p "${source_dir}"
      tar -xf "${cache_dir}/${archive}" --strip-components=1 -C "${source_dir}"
      read -r basever < "${source_dir}/gcc/BASE-VER"
      datestamp=$(< "${source_dir}/gcc/DATESTAMP")
      if [[ ${ref} != git:* ]]; then
        datestamp=${ref#*-}
      elif [[ ! ${datestamp} =~ ^[0-9]{8}$ ]]; then
        datestamp=$(date -u -r "${source_dir}/gcc/BASE-VER" +%Y%m%d)
      fi
      pkgver=${basever%%.*}.0.0+${datestamp}
      bash .github/scripts/apply-patches.sh "${source_dir}" "${repo_root}/patches"
      archive_dir=${repo_root}/work/archive-${combination}
      mkdir -p "${archive_dir}"
      mv "${source_dir}" "${archive_dir}/gcc-${pkgver}"
      printf 'GCC_PKGVER=%q\nGCC_BASEVER=%q\n' \
        "${pkgver}" "${basever}" > "${output_dir}/${combination}.env"
      tar -cJf "${output_dir}/${combination}.tar.xz" -C "${archive_dir}" "gcc-${pkgver}"
      rm -rf "${archive_dir}"
      prepared[${ref}]=${combination}
      ;;
    *) echo "Unknown mode: ${mode}" >&2; exit 2 ;;
  esac
done