/* Source: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
   Adapted from gcc.target/i386/pr54412-escaping-param.c:
   check an indirectly passed vector whose local address escapes. */
typedef float vector8 __attribute__((vector_size(32)));

__attribute__((noipa))
static vector8 load_vector(const vector8 *value)
{
    return *value;
}

__attribute__((noipa))
static vector8 pass_vector(vector8 value)
{
    return load_vector(&value);
}

__attribute__((noipa))
static int check_vector(void)
{
    vector8 input = {1, 2, 3, 4, 5, 6, 7, 8};
    vector8 output = pass_vector(input);
    return __builtin_memcmp(&input, &output, sizeof(input)) != 0;
}

__attribute__((target("no-avx")))
int main(void)
{
    if (!__builtin_cpu_supports("avx"))
        return 77;
    return check_vector();
}
