SOURCE=${TEST_DIR}/startup.c
CFLAGS+=" -mfpmath=387 -DEXPECTED_PRECISION=0x0000"
case $("${CC}" -dumpmachine) in
    *mingw*) CFLAGS+=" -mpc32" ;;
esac

# Skip until Cygwin's mingw-w64 got 67d0ab9
test_supported() {
  [[ ${TEST_COMBINATION} != cygwin-cross ]]
}
