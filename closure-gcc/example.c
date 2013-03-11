#include    <stdio.h>
#include    <closure_gcc.h>

int (*make_adder(int base, int base2))(int, int) {
    int a = 1;
    char arr[] = "hello";
    int (*adder)(int, int) = 
        _closure
            _lambda(int, int arg1, int arg2) {
                puts(arr);
                return arg1 + arg2 + a + base;
            }
        _closure_end;
    return adder;
}

int main(void) {
    int a = 1, b = 2;
    int (*adder)(int, int) = make_adder(3, 2);
    puts("ayayaya?");
    printf("%d\n", adder(a, b));
    _closure_free(adder);
    return 0;
}
