typedef double vector4 __attribute__((vector_size(32), aligned(32)));

static vector4 pass_vector(vector4 value)
{
    return value;
}

static int check_vector(void)
{
    vector4 input = {1.0, 2.0, 3.0, 4.0};
    vector4 output = pass_vector(input);
    return output[0] == 1.0 && output[3] == 4.0 ? 0 : 1;
}

__attribute__((target("no-avx")))
int main(void)
{
    if (!__builtin_cpu_supports("avx"))
        return 77;
    return check_vector();
}
