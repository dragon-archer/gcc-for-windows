# Smoke Tests

Each test lives in a directory containing `test*.sh`. The script sets `SOURCE`,
`CFLAGS`, or `CXXFLAGS`; the default compiler command is:

```sh
"${CC}" ${CFLAGS} "${SOURCE}" -o "${OUTPUT}"
```

Related cases share a directory with named `test-*.sh` scripts.
Each script runs independently;

Suites and cases run in filename order. `00-sanity` runs first and covers both
a successful program and the return-77 skip path.

A test script may define `compile_test` to use a custom command. The runner
selects `CC` and `CXX` from the packages just installed by CI, using explicit
target-prefixed compiler paths for cross builds. `CFLAGS` and `CXXFLAGS` are
strings loaded from makepkg configuration (including its configuration
fragments) or the cygport recipe's default environment.

Append options with `CFLAGS+=" -O0 -mavx"`. A C++ test can define:

```sh
compile_test() {
	"${CXX}" ${CXXFLAGS} -std=c++17 "${SOURCE}" -o "${OUTPUT}"
}
```

Compilation must return zero. The resulting program must return zero to pass,
77 to skip, and any other value to fail.

CI builds, installs packages, and runs tests in separate steps. Test output is
saved in the logs artifact as `tests.log`.
