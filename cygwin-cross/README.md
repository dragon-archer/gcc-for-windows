# Changes to [Cygwin's mingw64-x86_64-gcc.cygport](https://cygwin.com/cgit/cygwin-packages/mingw64-x86_64-gcc/tree/mingw64-x86_64-gcc.cygport)

1. Include both `libcaf_shmem.a` and `libcaf_single.a` in the Fortran package.
   > Can be upstreamed when updating to GCC 16
2. Match all `libatomic*` static libraries in the core package, including `libatomic_asneeded.a`.
   > Can be upstreamed when updating to GCC 16
3. Include `usr/lib/gcc/${TOOLCHAIN_TARGET}/${PVmaj}/testsuite`, following GCC 17's cygport
   > Can be upstreamed when updating to GCC 17
