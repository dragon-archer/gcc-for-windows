SOURCE=${TEST_DIR}/startup.c
CFLAGS+=" -mfpmath=387 -DEXPECTED_PRECISION=0x0300"
case $("${CC}" -dumpmachine) in
    *mingw*) CFLAGS+=" -mpc80" ;;
esac
