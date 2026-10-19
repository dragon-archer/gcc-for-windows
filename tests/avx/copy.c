/* Source: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
   Adapted from gcc.target/i386/pr54412-blkmode-temp-biggest-align.c:
   copy a plain 32-byte aggregate without assuming vector alignment. */
struct value {
    unsigned char bytes[32];
};

__attribute__((noipa))
static int check_value(struct value value)
{
    for (unsigned index = 0; index < sizeof(value.bytes); ++index)
        if (value.bytes[index] != index + 1)
            return 1;
    return 0;
}

__attribute__((noipa))
static int pass_value(const struct value *value)
{
    return check_value(*value);
}

__attribute__((noipa))
static int check_copy(void)
{
    struct value value;
    for (unsigned index = 0; index < sizeof(value.bytes); ++index)
        value.bytes[index] = index + 1;
    return pass_value(&value);
}

__attribute__((target("no-avx")))
int main(void)
{
    if (!__builtin_cpu_supports("avx"))
        return 77;
    return check_copy();
}
