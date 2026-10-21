# Changes to [MSYS2-packages/gcc/PKGBUILD](https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD)

- Enable `STAGE1_CFLAGS="-O2"` to speed up.
- Add `-O` to `make` so that the output is more readable.
- Drop `0002-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
- Drop `0101-Cygwin-enable-libgccjit-not-just-for-MingW.patch`
  > Has been fixed upstream in r17-5417-gfbbe6708ef01b2
