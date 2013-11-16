#include    <stdio.h>
#include    <list_tmpl.h>

struct point2d {
    int x, y;
    list_ctl_t lctl;
};

int main(void) {
    struct point2d p = { .x = 1, .y = 2 };
    
    list_ctl_t h;
    init_list_head(&h);
    list_add_tail(&(p.lctl), &h);

    iter_type(struct point2d) itr;
    list_foreach(itr, &h) {
        itr2obj(point, itr);
        printf("%d %d\n", point->x, point->y);
    }

    return 0;
}
