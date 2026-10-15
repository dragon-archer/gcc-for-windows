# Changes to [MINGW-packages/mingw-w64-gcc/PKGBUILD](https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD)

1. Use `_pkgver` instead of `pkgver` in `_libdir`, `gdbinit`, and `share/`.
   > Can be upstreamed on next cleanup.
2. Drop `0002-i386-Keep-SEH-enabled-for-Win64-sysv_abi-functions.patch`, already applied in upstream GCC.
   > Can be upstreamed when updating to GCC 17.
