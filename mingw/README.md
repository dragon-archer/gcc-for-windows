# Changes to [MINGW-packages/mingw-w64-gcc/PKGBUILD](https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD)

- Use `_pkgver` instead of `pkgver` in `_libdir`, `gdbinit`, and `share/`.
  > Can be upstreamed on next cleanup.
- Drop `0002-i386-Keep-SEH-enabled-for-Win64-sysv_abi-functions.patch`
  > Has been fixed upstream in r17-443-gb0f09b72d9e178
- Drop `0200-add-m-no-align-vector-insn-option-for-i386.patch`
  > Has been fixed upstream in r17-4649-g8aaa5f6e62075c
- Regenerate `0022-mingw-Remove-outdated-mingw-stuff.patch`
  > Part of it has been fixed upstream in r17-5098-ga80b0de184f0f7
- Drop `0007-Build-EXTRA_GNATTOOLS-for-Ada.patch`
  > Has been fixed upstream in r17-5466-g736e07ca6a2a6c
- Drop `0008-Prettify-linking-no-undefined.patch`
  > No longer needed. Can be backported.
