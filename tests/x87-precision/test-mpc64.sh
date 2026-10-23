SOURCE=${TEST_DIR}/startup.c
CFLAGS+=" -mfpmath=387 -DEXPECTED_PRECISION=0x0200"
case $("${CC}" -dumpmachine) in
    *mingw*) CFLAGS+=" -mpc64" ;;
esac
