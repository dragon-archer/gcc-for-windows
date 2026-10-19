/* Source: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
   Adapted from gcc.target/i386/pr54412-aligned-struct-byval-temp.c:
   check alignment and contents of a caller-created argument temporary. */
#include <stdint.h>

struct aligned_value {
    unsigned char bytes[32];
} __attribute__((aligned(32)));

__attribute__((noipa))
static int check_value(struct aligned_value value)
{
    if ((uintptr_t)&value % 32 != 0)
        return 1;
    for (unsigned index = 0; index < sizeof(value.bytes); ++index)
        if (value.bytes[index] != index + 1)
            return 1;
    return 0;
}

__attribute__((noipa))
static int pass_value(const struct aligned_value *value)
{
    return check_value(*value);
}

int main(void)
{
    struct aligned_value value;
    for (unsigned index = 0; index < sizeof(value.bytes); ++index)
        value.bytes[index] = index + 1;
    return pass_value(&value);
}
