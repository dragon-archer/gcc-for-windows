# Changes to [Cygwin's gcc.cygport](https://cygwin.com/cgit/cygwin-packages/gcc/tree/gcc.cygport)

- Don't override BOOT_CFLAGS, use default `-g -O2`.
- Add `--disable-werror` for now.
  > `__gnat_personality_seh0` in `gcc/ada/raise-gcc.c` triggered `-Wclobbered`.
- Drop `0002-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
- Drop `0101-Cygwin-enable-libgccjit-not-just-for-MingW.patch`
  > Has been fixed upstream in r17-5417-gfbbe6708ef01b2
