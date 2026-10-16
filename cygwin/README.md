# Changes to [Cygwin's gcc.cygport](https://cygwin.com/cgit/cygwin-packages/gcc/tree/gcc.cygport)

1. Don't override BOOT_CFLAGS, use default `-g -O2`.
2. Add `--disable-werror` for now.
   > `__gnat_personality_seh0` in `gcc/ada/raise-gcc.c` triggered `-Wclobbered`.
