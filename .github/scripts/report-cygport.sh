#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

mode=${1:?snapshot or report is required}
report_dir=artifacts/logs/package-reports
mkdir -p "${report_dir}"
exec > >(tee -a "${report_dir}/report.log") 2>&1
IFS=, read -r -a packages < work/repository/packages.txt
cygcheck -cd > "${report_dir}/${mode}-installed.txt"
export PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin:${PATH}

normalize_version() {
  local version=${1%-*} major path
  major=${version%%.*}
  while IFS= read -r path; do
    path=${path//"${version}"/PKGVER}
    path=${path//"/${major}/"/\/PKGVER\/}
    printf '%s\n' "${path//"gcc-${major}/"/gcc-PKGVER/}"
  done
}

for package in "${packages[@]}"; do
  version=$(awk -v package="${package}" '$1 == package { print $2 }' "${report_dir}/${mode}-installed.txt")
  case ${mode} in
    snapshot)
      if [[ -n ${version} ]]; then
        printf '%s %s\n' "${package}" "${version}" > "${report_dir}/${package}-official.meta"
        cygcheck -l "${package}" | normalize_version "${version}" |
          sort > "${report_dir}/${package}-official.files"
      fi
      ;;
    report)
      if [[ -z ${version} ]]; then
        echo "Package is not installed: ${package}" >&2
        exit 1
      fi
      printf '%s %s\n' "${package}" "${version}" > "${report_dir}/${package}-built.meta"
      cygcheck -l "${package}" > "${report_dir}/${package}-installed.files"
      if [[ -f ${report_dir}/${package}-official.meta ]]; then
        echo "::group::[meta-diff] ${package} (installed version)"
        diff -u "${report_dir}/${package}-official.meta" "${report_dir}/${package}-built.meta" || true
        echo '::endgroup::'

        echo "::group::[file-diff] ${package}"
        normalize_version "${version}" < "${report_dir}/${package}-installed.files" |
          sort > "${report_dir}/${package}-built.files"
        diff -u "${report_dir}/${package}-official.files" "${report_dir}/${package}-built.files" || true
        echo '::endgroup::'
      else
        echo "No preinstalled official baseline for ${package}."
        cat "${report_dir}/${package}-built.meta"
      fi

      echo "::group::[runtime-dependencies] ${package}"
      while IFS= read -r binary; do
        case ${binary,,} in
          *.exe|*.dll|*.pyd)
            echo "${binary}:"
            cygcheck "${binary}" || true
            ;;
        esac
      done < "${report_dir}/${package}-installed.files"
      echo '::endgroup::'
      ;;
    *) echo "Unknown report mode: ${mode}" >&2; exit 2 ;;
  esac
done
