# Changes to [Cygwin's gcc.cygport](https://cygwin.com/cgit/cygwin-packages/gcc/tree/gcc.cygport)

1. Don't override BOOT_CFLAGS, use default `-g -O2`.
2. Add `--disable-werror` for now.
   > `__gnat_personality_seh0` in `gcc/ada/raise-gcc.c` triggered `-Wclobbered`.
3. Drop `0002-add-m-no-align-vector-insn-option-for-i386.patch`
   > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
4. Move several patches to upstream:
   - 0005-Cygwin-handle-dllimport-properly-in-medium-model-V2.patch
   - 0006-Cygwin-MinGW-skip-test.patch
   - 0009-Cygwin-libgomp-soname.patch
   - 0010-Cygwin-g-time.patch
   - 0012-Cygwin-define-STD_UNIX.patch
