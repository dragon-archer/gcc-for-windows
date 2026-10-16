# Changes to [MINGW-packages/mingw-w64-gcc/PKGBUILD](https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD)

1. Use `_pkgver` instead of `pkgver` in `_libdir`, `gdbinit`, and `share/`.
   > Can be upstreamed on next cleanup.
2. Drop `0002-i386-Keep-SEH-enabled-for-Win64-sysv_abi-functions.patch`, already applied in upstream GCC.
   > Can be upstreamed when updating to GCC 17.
3. Drop `0200-add-m-no-align-vector-insn-option-for-i386.patch`
   > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
