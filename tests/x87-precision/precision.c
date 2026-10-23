/* Source: LIU Hao, gcc-patches, 2026-10-19.
   https://inbox.sourceware.org/gcc-patches/dce01e82-038b-40a3-a460-31054dfb20e0@126.com/
   Adaptation: use x87 control-word instructions instead of _control87,
   which is unavailable on Cygwin/MSYS2 and does not set x87 precision
   through the Microsoft x64 CRT.
   Compile with -mfpmath=387. Requires native x86 floating-point behavior;
   ARM64 x86 emulation may not implement x87 precision control. */
#include <assert.h>

enum { X87_PC_24 = 0x0000, X87_PC_53 = 0x0200, X87_PC_64 = 0x0300 };

__attribute__((noipa))
static void set_precision(unsigned short precision)
{
    unsigned short control;
    __asm__ volatile ("fnstcw %0" : "=m" (control));
    control = (control & ~0x0300u) | precision;
    __asm__ volatile ("fldcw %0" : : "m" (control) : "memory");
}

int main(void)
{
    static volatile long double l_eps = 0x0.0000000000000002p0L;
    static volatile long double l_1eps = 0x1.0000000000000002p0L;
    static volatile double d_eps = 0x0.0000000000001p0;
    static volatile double d_1eps = 0x1.0000000000001p0;

    assert(l_1eps != 1);
    assert(d_1eps != 1);

    assert(1 + l_eps == l_1eps);
    assert(1 + d_eps == d_1eps);

    set_precision(X87_PC_53);
    assert(1 + l_eps == 1);
    assert(1 + d_eps == d_1eps);

    set_precision(X87_PC_24);
    assert(1 + l_eps == 1);
    assert(1 + d_eps == 1);

    set_precision(X87_PC_64);
    assert(1 + l_eps == l_1eps);
    assert(1 + d_eps == d_1eps);
    return 0;
}
