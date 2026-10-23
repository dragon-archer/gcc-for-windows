/* Regression test for Peter Damianov's -mpc32/-mpc64/-mpc80 patch.
   https://inbox.sourceware.org/gcc-patches/20261018213448.154054-1-peter0x44@disroot.org/
   Numerical checks adapted from LIU Hao's reply:
   https://inbox.sourceware.org/gcc-patches/dce01e82-038b-40a3-a460-31054dfb20e0@126.com/
   Do not set the control word here: the driver-selected startup object
   must establish the precision before main. */
#include <stdio.h>

int main(void)
{
#ifdef __MINGW32__
    unsigned short control;
    __asm__ volatile ("fnstcw %0" : "=m" (control));
    if ((control & 0x0300u) != EXPECTED_PRECISION) {
        fprintf(stderr, "x87 precision: expected %#x, got %#x (CW=%#x)\n",
                EXPECTED_PRECISION, control & 0x0300u, (unsigned)control);
        return 1;
    }

    static volatile long double l_eps = 0x0.0000000000000002p0L;
    static volatile double d_eps = 0x0.0000000000001p0;
    volatile long double l_sum = 1.0L + l_eps;
    volatile double d_sum = 1.0 + d_eps;
    return l_sum != (EXPECTED_PRECISION == 0x0300 ? 0x1.0000000000000002p0L : 1.0L)
        || d_sum != (EXPECTED_PRECISION == 0x0000 ? 1.0 : 0x1.0000000000001p0);
#else
    return 77;
#endif
}
