# Changes to [MSYS2-packages/mingw-w64-cross-gcc/PKGBUILD](https://github.com/msys2/MSYS2-packages/blob/master/mingw-w64-cross-gcc/PKGBUILD)

- Introduce `_pkgver` for the GCC version and use it instead of `pkgver` in the version-specific runtime library and executable paths.
  > Can be upstreamed on next cleanup.
- Drop `0200-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
- Drop `0101-Cygwin-enable-libgccjit-not-just-for-MingW.patch`
  > Has been fixed upstream in r17-5417-gfbbe6708ef01b2
