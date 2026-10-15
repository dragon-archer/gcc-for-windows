# Changes to [MSYS2-packages/gcc/PKGBUILD](https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD)

1. Introduce `_pkgver` for the GCC version and use it instead of `pkgver` in `share/`.
   > Can be upstreamed on next cleanup.
2. Sync `0101-Cygwin-enable-libgccjit-not-just-for-MingW.patch` with the Cygwin GCC 17 source package and update its checksum.
   > Can be upstreamed when updating to GCC 17.
