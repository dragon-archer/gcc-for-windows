# GCC for Windows

[![GCC build tests](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml/badge.svg)](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

A unified CI/CD pipeline for building and testing GCC across native Windows (MSYS2/MinGW-w64), Cygwin, and Linux environments.

This repository automates the preparation of GCC source snapshots and manages build recipes to ensure consistency and facilitate rapid testing of patches across multiple toolchains.

## Supported Environments

| Build Combination | Host | Target | Toolchain | Status |
| :--- | :--- | :--- | :--- | :--- |
| **MSYS2** | MSYS2 | Native MSYS2 | `makepkg` | [![MSYS2][status-msys2]][ci] |
| **MSYS2 Cross** | MSYS2 | MinGW-w64 | `makepkg` | [![MINGW32][status-msys2-cross-mingw32]][ci] [![MINGW64][status-msys2-cross-mingw64]][ci] [![UCRT64][status-msys2-cross-ucrt64]][ci] |
| **MinGW** | MinGW-w64 | Native MinGW-w64 | `makepkg-mingw` | [![MINGW32][status-mingw-mingw32]][ci] [![MINGW64][status-mingw-mingw64]][ci] [![UCRT64][status-mingw-ucrt64]][ci] |
| **Cygwin** | Cygwin | Native Cygwin | `cygport` | [![Cygwin][status-cygwin]][ci] |
| **Cygwin Cross** | Cygwin | Win64 (MinGW) | `cygport` | [![Win64][status-cygwin-cross]][ci] |
| **Linux (Control)** | Ubuntu | x86_64-linux | `configure/make` | [![Ubuntu][status-ubuntu]][ci] |

[ci]: https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml?query=branch%3Amain
[status-ubuntu]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/ubuntu%20%2F%20x86_64-linux-gnu?label=Ubuntu
[status-msys2]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/msys2%20%2F%20msys?label=MSYS2
[status-msys2-cross-mingw32]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/msys2-cross%20%2F%20mingw32?label=MINGW32
[status-msys2-cross-mingw64]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/msys2-cross%20%2F%20mingw64?label=MINGW64
[status-msys2-cross-ucrt64]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/msys2-cross%20%2F%20ucrt64?label=UCRT64
[status-mingw-mingw32]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/mingw%20%2F%20mingw32?label=MINGW32
[status-mingw-mingw64]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/mingw%20%2F%20mingw64?label=MINGW64
[status-mingw-ucrt64]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/mingw%20%2F%20ucrt64?label=UCRT64
[status-cygwin]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/cygwin%20%2F%20cygwin?label=Cygwin
[status-cygwin-cross]: https://badgen.net/github/checks/dragon-archer/gcc-for-windows/main/cygwin-cross%20%2F%20cygwin-cross?label=Win64

These combinations run as 10 parallel build jobs.

## Build Results

Open [GitHub Actions](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml)
and select a run to inspect individual jobs or download artifacts:

## Build Artifacts

GitHub Actions produces several types of artifacts for each run:

- **`gcc-sources`**: Prepared GCC source archives and version metadata shared across all build jobs.
- **`<combination>-<environment>-packages`**: MSYS2/MinGW binary package archives.
- **`<combination>-packages`**: Cygwin distribution files, including packages and setup metadata.
- **`-logs` artifacts**: Detailed build logs, diagnostic reports, and the effective recipes used.

Source artifacts are retained for 7 days; all other packages and logs are retained for 14 days.

## Build Pipeline Workflow

Each push or pull request initiates the following workflow:

1. **Preparation**: Download or restore GCC source archives, apply common patches, and publish the prepared source artifact.
2. **Parallel Compilation**: Downstream jobs fetch the prepared source and execute native build commands (`makepkg`, `cygport`, or `make`).
3. **Packaging & Validation**: The toolchain creates installable packages, installs them, and runs integrated smoke tests.

The CI automates these invocations:

```bash
# MSYS2/MinGW
makepkg -CfLrs --noconfirm

# Cygwin
cygport <recipe> prep compile install package
```

Workflow definitions:
- [Entry Workflow](.github/workflows/build.yml)
- [MSYS2 Build](.github/workflows/makepkg.yml)
- [Cygwin Build](.github/workflows/cygport.yml)
- [Linux Control](.github/workflows/ubuntu.yml)

### Linux Control Environment

The [ubuntu/](ubuntu/) directory acts as a native Linux reference platform. It uses the same source preparation logic but runs a standard `configure` and `make` build sequence to ensure cross-platform consistency.

## Managing GCC Sources

The build uses a `gcc-ref` file to determine the source version. This can be defined at the repository root or within a specific combination directory.

- **Snapshot**: `17-20261115`
- **Git Revision**: `git:releases/gcc-16.2.0` (from [gcc-mirror/gcc](https://github.com/gcc-mirror/gcc))

## Recipes and Patch Management

Recipes are derived from [MSYS2](https://github.com/msys2/MSYS2-packages), [MINGW](https://github.com/msys2/MINGW-packages), and [Cygwin](https://cygwin.com/packages/) repositories.

- [patches/](patches/): Common patches applied automatically to all builds.
- Combination-specific patches: Located within subdirectories (e.g., `mingw/`, `cygwin/`).

## License

Original project code is licensed under the **GNU General Public License, version 3**. See [LICENSE](LICENSE) for details.

Third-party recipes, patches, GCC source, and runtime libraries are subject to their respective licenses.
