# Changes to [MSYS2-packages/mingw-w64-cross-gcc/PKGBUILD](https://github.com/msys2/MSYS2-packages/blob/master/mingw-w64-cross-gcc/PKGBUILD)

1. Introduce `_pkgver` for the GCC version and use it instead of `pkgver` in the version-specific runtime library and executable paths.
   > Can be upstreamed on next cleanup.
2. Drop `0200-add-m-no-align-vector-insn-option-for-i386.patch`
   > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
3. Move several patches to upstream:
   - 0003-Cygwin-handle-dllimport-properly-in-medium-model-V2.patch
   - 0004-Cygwin-MinGW-skip-test.patch
   - 0008-Cygwin-libgomp-soname.patch
   - 0009-Cygwin-g-time.patch
   - 0011-Cygwin-define-STD_UNIX.patch
