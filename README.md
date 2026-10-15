# GCC for Windows

[![GCC build tests](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml/badge.svg)](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Build and test GCC snapshots across MSYS2, MinGW-w64, and Cygwin using their
native packaging tools.

Test newer GCC sources, check patches, and compare builds across environments
in a single CI pipeline, using recipes from MSYS2 and Cygwin.

## Supported Builds

| Combination | Host environment | Compiler target | Packaging tool |
| --- | --- | --- | --- |
| [msys2](msys2/) | MSYS2 | Native MSYS2 | `makepkg` |
| [msys2-cross](msys2-cross/) | MSYS2 | MinGW-w64: mingw32, mingw64, ucrt64 | `makepkg` |
| [mingw](mingw/) | MINGW32, MINGW64, UCRT64 | Native MinGW-w64 in each environment | `makepkg-mingw` |
| [cygwin](cygwin/) | Cygwin x86_64 | Native Cygwin | `cygport` |
| [cygwin-cross](cygwin-cross/) | Cygwin x86_64 | `x86_64-w64-mingw32` | `cygport` |

These combinations run as nine parallel build jobs.

## Build Results

Open [GitHub Actions](https://github.com/dragon-archer/gcc-for-windows/actions/workflows/build.yml)
and select a run to inspect individual jobs or download artifacts:

- **`gcc-sources`**: prepared source archives and version metadata shared by the builds.
- **`<combination>-<environment>-packages`**: MSYS2/MinGW package archives.
- **`<combination>-packages`**: Cygwin distribution files, including binary/source packages and setup hints.
- **Corresponding `-logs` artifacts**: build logs, diagnostics, and the recipes used for the run.

Source artifacts are retained for seven days; packages and logs for fourteen
days.

## Build Pipeline

Every push and pull request starts the workflow:

1. **Prepare on Ubuntu.** Download or restore the selected GCC archives, apply
	 common patches, and publish prepared sources. Combinations using the same
	 source reference share the preparation work. The cache stores original downloads.
2. **Build on Windows.** Each job downloads the prepared sources and uses its
	 own environment: MSYS2 for makepkg builds, Cygwin for cygport builds.
3. **Package and publish.** The native packaging tool applies recipe-specific
	 patches, compiles GCC, installs into a staging directory, and produces packages.
	 CI uploads the resulting packages and diagnostics.

CI sets the source archive and package version in a working copy of each
recipe, then invokes its packaging tool:

```sh
makepkg -CfLrs --noconfirm
makepkg-mingw -CfLrs --noconfirm
cygport <recipe> prep compile install package
```

See [build.yml](.github/workflows/build.yml) for the entry workflow,
[makepkg.yml](.github/workflows/makepkg.yml) for MSYS2 builds, and
[cygport.yml](.github/workflows/cygport.yml) for Cygwin builds.

## Selecting GCC Sources

Each combination has an independent, single-line `gcc-ref` file:

| Combination | Source selection |
| --- | --- |
| MSYS2 native | [msys2/gcc-ref](msys2/gcc-ref) |
| MSYS2 cross | [msys2-cross/gcc-ref](msys2-cross/gcc-ref) |
| MinGW native | [mingw/gcc-ref](mingw/gcc-ref) |
| Cygwin native | [cygwin/gcc-ref](cygwin/gcc-ref) |
| Cygwin cross | [cygwin-cross/gcc-ref](cygwin-cross/gcc-ref) |

Use a GCC snapshot identifier, for example:

```text
16-20261010
```

To test a specific Git revision, prefix a full commit SHA or tag with `git:`:

```text
git:releases/gcc-16.1.0
```

Snapshots come from the GCC download server; Git archives come from
[gcc-mirror/gcc](https://github.com/gcc-mirror/gcc). Push the updated reference
or open a pull request to start a build.

Snapshot package versions include the date, such as `16.0.0+20261010`.
GCC's internal installation version remains controlled by the source and recipe.

## Recipes and Patches

Recipes are based on [MSYS2-packages](https://github.com/msys2/MSYS2-packages),
[MINGW-packages](https://github.com/msys2/MINGW-packages), and Cygwin source
packages.

- [patches/](patches/) contains common patches, applied in filename order with
	`patch -Np1` to every selected source version before recipe-specific preparation.
- Combination-specific patches live beside their `PKGBUILD` or `.cygport`
	recipe. The recipe defines their application order.

Update recipes together with their patches, auxiliary files, and checksums.
For makepkg builds, the prepared GCC archive uses `SKIP`; patches and other
inputs are checked against the recipe's checksums.

For patches and bug reports, include the build combination, GCC reference,
and CI link. A short excerpt around the first error helps locate build failures.

## License

Original project code is licensed under the GNU General Public License,
version 3. See [LICENSE](LICENSE) for the full text.

Imported recipes, patches, GCC, and its runtime libraries retain their
respective licenses and exceptions.
