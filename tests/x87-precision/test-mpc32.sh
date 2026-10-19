SOURCE=${TEST_DIR}/startup.c
CFLAGS+=" -mfpmath=387 -DEXPECTED_PRECISION=0x0000"

# Skip until other's mingw-w64 got 67d0ab9 for CRT_fp4.o
test_supported() {
  [[ ${TEST_COMBINATION} == mingw ]]
}

if test_supported; then
    case $("${CC}" -dumpmachine) in
        *mingw*) CFLAGS+=" -mpc32" ;;
    esac
fi
