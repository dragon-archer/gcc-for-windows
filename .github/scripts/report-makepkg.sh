#!/usr/bin/env bash
set -euo pipefail

combination=${1:?combination is required}
export LC_ALL=C
repository=msys
if [[ ${combination} == mingw ]]; then
  repository=${MSYSTEM,,}
  dependency_tool=${MINGW_PREFIX}/bin/ntldd
  dependency_package=${MINGW_PACKAGE_PREFIX}-ntldd
elif [[ ${combination} == msys2-cross ]]; then
  dependency_tool=/ucrt64/bin/ntldd
  dependency_package=mingw-w64-ucrt-x86_64-ntldd
fi

report_dir=artifacts/logs/package-reports
mkdir -p "${report_dir}"
exec > >(tee "${report_dir}/report.log") 2>&1

pacman --noconfirm -Fy
if [[ ${combination} != msys2 ]]; then
  pacman -S --needed --noconfirm "${dependency_package}"
fi

normalize_version() {
  awk -v version="$1" '{
    while ((position = index($0, version)) != 0)
      $0 = substr($0, 1, position - 1) "PKGVER" substr($0, position + length(version));
    print;
  }'
}

for package_file in artifacts/packages/*.pkg.tar.*; do
  package=$(pacman -Qp "${package_file}" | cut -d ' ' -f 1)
  new_version=$(pacman -Qp "${package_file}" | cut -d ' ' -f 2)
  new_version=${new_version%-*}
  new_version=${new_version#*~}

  if pacman -Si "${repository}/${package}" > "${report_dir}/${package}-official.meta"; then
    old_version=$(sed -n 's/^Version[[:space:]]*:[[:space:]]*//p' "${report_dir}/${package}-official.meta")
    old_version=${old_version%-*}
    old_version=${old_version#*~}

    echo "::group::[meta-diff] ${package}"
    sed -i '/Download Size/d' "${report_dir}/${package}-official.meta"
    pacman -Qip "${package_file}" | sed '/Compressed Size/d' > "${report_dir}/${package}-built.meta"
    diff -u "${report_dir}/${package}-official.meta" "${report_dir}/${package}-built.meta" || true
    echo '::endgroup::'

    echo "::group::[file-diff] ${package}"
    pacman -Fl "${repository}/${package}" | sed 's|^[^ ]* |/|' |
      normalize_version "${old_version}" | sort > "${report_dir}/${package}-official.files"
    pacman -Qlq "${package}" | normalize_version "${new_version}" |
      sort > "${report_dir}/${package}-built.files"
    diff -u "${report_dir}/${package}-official.files" "${report_dir}/${package}-built.files" || true
    echo '::endgroup::'
  else
    echo "No official ${repository}/${package} baseline; skipping package comparison."
  fi

  echo "::group::[runtime-dependencies] ${package}"
  while IFS= read -r binary; do
    case ${binary,,} in
      *.exe|*.dll|*.pyd)
        echo "${binary}:"
        if [[ ${combination} == msys2 ]]; then
          ldd "${binary}" || true
        else
          "${dependency_tool}" -R "${binary}" |
            grep -viE 'ext-ms|api-ms|[\\/]windows[\\/]' || true
        fi
        ;;
    esac
  done < <(pacman -Qlq "${package}")
  echo '::endgroup::'
done
