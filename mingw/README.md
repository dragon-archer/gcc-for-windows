# Changes to [MINGW-packages/mingw-w64-gcc/PKGBUILD](https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD)

- Use `_pkgver` instead of `pkgver` in `_libdir`, `gdbinit`, and `share/`.
  > Can be upstreamed on next cleanup.
- Drop `0002-i386-Keep-SEH-enabled-for-Win64-sysv_abi-functions.patch`
  > Has been fixed upstream in r17-443-gb0f09b72d9e178
- Drop `0200-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4650-g4a0bca2e9e9193
- Regenerate `0022-mingw-Remove-outdated-mingw-stuff.patch`
  > Rename to `0022-MSYS2-Set-STANDARD_STARTFILE_PREFIX_1-to-lib.patch`
  > Part of it has been fixed upstream in r17-5098-ga80b0de184f0f7
  > Part of it moved to common patches
- Drop `0007-Build-EXTRA_GNATTOOLS-for-Ada.patch`
  > Has been fixed upstream in r17-5466-g736e07ca6a2a6c
