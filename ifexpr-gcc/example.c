#include    <stdio.h>
#include    <ifexpr_gcc.h>

int main(void) {
    int a = 0;
    scanf("%d", &a);

    int b = if_(a == 1) {
        puts("branch 1");
        1;
    } else_ {
        if_ (a == 2) {
            2;
        } else_ {
            3;
        } endif_;
    } endif_;

    printf("branch=%d\n", b);

    return 0;
}
