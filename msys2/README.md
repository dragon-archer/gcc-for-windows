# Changes to [MSYS2-packages/gcc/PKGBUILD](https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD)

- Enable `STAGE1_CFLAGS="-O2"` to speed up.
- Add `-O` to `make` so that the output is more readable.
- Drop `0002-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
- Drop `0101-Cygwin-enable-libgccjit-not-just-for-MingW.patch`
  > Has been fixed upstream in r17-5417-gfbbe6708ef01b2
- Drop `0001-Always-define-WIN32_LEAN_AND_MEAN-before-windows.h.patch`
  > Has been fixed upstream in r17-5485-g49f3e5d51a00ac
- Move several patches to upstream:
  * 0005-Cygwin-handle-dllimport-properly-in-medium-model-V2.patch
  * 0009-Cygwin-libgomp-soname.patch
  * 0010-Cygwin-g-time.patch
  * 0012-Cygwin-define-STD_UNIX.patch
