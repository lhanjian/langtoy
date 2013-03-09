#ifndef     _DEFER_GCC_H_
#define     _DEFER_GCC_H_

#include    <util_list.h>

struct _defer {
    void *label;
    list_ctl_t lctl;
};

#define     defer_begin \
    __label__ do_call; \
    list_ctl_t _defer_queue_, *_p_; \
    struct _defer *_d_, *_dp_; \
    do { init_list_head(&_defer_queue_); } while (0)

#define     defer(_f_, ...) \
    do { \
        __label__ init_call, code_call; \
        _d_ = (struct _defer *) __builtin_alloca(sizeof(struct _defer)); \
        goto init_call; \
        code_call: \
        _f_(__VA_ARGS__); \
        goto do_call; \
        init_call: \
        _d_->label = &&code_call; \
        list_add_tail(&(_d_->lctl), &_defer_queue_); \
    } while (0)

#define     defer_end \
    do { \
        _p_ = _defer_queue_.next; \
        while (_p_ != &_defer_queue_) { \
            _dp_ = container_of(_p_, struct _defer, lctl); \
            goto *(_dp_->label); \
            do_call: \
            _p_ = _p_->next; \
        } \
    } while (0)


#endif      // _DEFER_GCC_H_
