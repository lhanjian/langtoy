#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>
#include    <defer_gcc.h>

void free_wrap(void *p) {
    printf("free %s", (char *) p);
    free(p);
}

int main(void) {
    {
        defer_begin;

        char *p = (char *) malloc(sizeof(char) * 32);
        defer(free_wrap, p);
        defer(printf, "[4] defer test\n");
        memset(p, 0, sizeof(char) * 32);
        strcpy(p, "[3] hello defer\n");

        {
            defer_begin;

            char *p = (char *) malloc(sizeof(char) * 32);
            defer(free_wrap, p);
            defer(printf, "[2] defer test2\n");
            memset(p, 0, sizeof(char) * 32);
            strcpy(p, "[1] hello defer 2\n");

            defer_end;
        }

        char *p1 = (char *) malloc(sizeof(char) * 32);
        strcpy(p1, "[5] hello again\n");
        defer(free_wrap, p1);

        defer_end;
    } 

    printf("exit\n");
    return 0;
}
