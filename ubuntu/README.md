# Ubuntu Control

Build GCC on the default `ubuntu-latest` x86_64 environment. `gcc-ref` selects
the source through `.github/scripts/prepare-sources.sh`, just like the other
combinations. Downloads, caching, common patches, version metadata, and the
`gcc-sources` artifact use the shared pipeline; identical refs share preparation.
No MSYS2 recipes or environment settings are used.

`build.sh` extracts `work/sources/ubuntu.tar.xz`, then runs an out-of-tree
configure, parallel make, and installation into the default `/usr/local`
prefix. Configure only selects `x86_64-linux-gnu` as
the native build tuple and limits the front ends to C/C++; bootstrap, multilib,
warning handling, and all other settings retain their upstream defaults.
Build dependencies include `g++-multilib` for the default multilib build.
`ldconfig` registers the installed 64-bit runtime libraries without changing
the test environment.

The shared runner executes `tests/*/test*.sh` using `gcc` and `g++` from the
default PATH, including C/C++ sanity checks. CI uploads build, configure, and
test logs, but does not package the compiler or run the full DejaGNU testsuite.
