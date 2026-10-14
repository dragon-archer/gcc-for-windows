pkgver=${GCC_PKGVER}
pkgrel=1
_gcc_basever=${GCC_BASEVER}

if [[ ${GCC_COMBINATION} == mingw ]]; then
  source=("gcc-${GCC_PKGVER}.tar.xz" "${source[@]:2}")
  sha256sums=(SKIP "${sha256sums[@]:2}")
  _sourcedir=gcc-${pkgver}
  _libdir=lib/gcc/${CHOST}/${_gcc_basever}
else
  source=("gcc-${GCC_PKGVER}.tar.xz" "${source[@]:1}")
  sha256sums=(SKIP "${sha256sums[@]:1}")
fi

if [[ ${GCC_COMBINATION} == msys2-cross ]]; then
  _targetpkgs=("${_mingw_suff}-${GCC_ENVIRONMENT}-${_realname}")
  pkgname=("${_targetpkgs[@]}")
  for dependency_index in "${!makedepends[@]}"; do
    makedepends[dependency_index]=${makedepends[dependency_index]/${_mingw_suff}-/${_mingw_suff}-${GCC_ENVIRONMENT}-}
  done
fi