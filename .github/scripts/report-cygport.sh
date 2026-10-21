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

if [[ ${mode} == snapshot ]]; then
  curl -fsSL "${CYGWIN_MIRROR}/x86_64/setup.xz" |
    xz -dc > "${report_dir}/official-setup.ini"
fi

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
      else
        official_package=$(awk -v package="${package}" '
          $1 == "@" { selected = ($2 == package) }
          selected && $1 == "version:" { version = $2 }
          selected && $1 == "install:" { print version, $2, $4; exit }
        ' "${report_dir}/official-setup.ini")
        if [[ -z ${official_package} ]]; then
          echo "::notice::No official package baseline for ${package}."
          continue
        fi
        read -r version archive checksum <<< "${official_package}"
        archive_file=${report_dir}/${archive##*/}
        curl -fsSL "${CYGWIN_MIRROR}/${archive}" -o "${archive_file}"
        printf '%s  %s\n' "${checksum}" "${archive_file}" | sha512sum -c -
        printf '%s %s\n' "${package}" "${version}" > "${report_dir}/${package}-official.meta"
        tar -tf "${archive_file}" | sed -e '/\/$/d' -e 's|^\./||' -e 's|^|/|' |
          normalize_version "${version}" | sort > "${report_dir}/${package}-official.files"
        rm "${archive_file}"
      fi
      ;;
    report)
      if [[ -z ${version} ]]; then
        echo "Package is not installed: ${package}" >&2
        exit 1
      fi
      expected_version=$(awk -v package="${package}" '
        $1 == "@" { selected = ($2 == package) }
        selected && $1 == "version:" { print $2; exit }
      ' work/repository/x86_64/setup.ini)
      if [[ -z ${expected_version} || ${version} != "${expected_version}" ]]; then
        echo "Installed version mismatch for ${package}: expected ${expected_version:-missing from local repository}, got ${version}" >&2
        exit 1
      fi
      printf '%s %s\n' "${package}" "${version}" > "${report_dir}/${package}-built.meta"
      cygcheck -l "${package}" > "${report_dir}/${package}-installed.files"
      normalize_version "${version}" < "${report_dir}/${package}-installed.files" |
        sort > "${report_dir}/${package}-built.files"
      if [[ -f ${report_dir}/${package}-official.meta ]]; then
        echo "::group::[meta-diff] ${package} (installed version)"
        diff -u "${report_dir}/${package}-official.meta" "${report_dir}/${package}-built.meta" || true
        echo '::endgroup::'

        echo "::group::[file-diff] ${package}"
        diff -u "${report_dir}/${package}-official.files" "${report_dir}/${package}-built.files" || true
        echo '::endgroup::'
      else
        echo "::notice::No official package baseline for ${package}; skipping package comparison."
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
