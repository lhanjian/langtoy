#ifndef     _CLOSURE_GCC_H_
#define     _CLOSURE_GCC_H_

#include    <stdlib.h>
#include    <string.h>

#define unlikely(_x_)   __builtin_expect(!!(_x_), 0)

#define _closure    ({
#define _lambda(_rt_, ...) \
        _rt_ $(__VA_ARGS__)
#define _closure_end    \
        void *_rsp_, *_rbp_, *_cntx_; \
        asm volatile ("movq %%rsp, %0" : "=r" (_rsp_)); \
        asm volatile ("movq %%rbp, %0" : "=r" (_rbp_)); \
        char *_tramp_ = (char *) malloc(sizeof(char) * (19 + (unsigned long) (_rbp_-_rsp_))); \
        memcpy(_tramp_, $, 19); \
        _cntx_ = *((void **) (&_tramp_[8])); \
        memcpy(_tramp_ + 19, _cntx_, (unsigned long) (_rbp_ - _cntx_)); \
        *((void **) (&_tramp_[8])) = \
                (void *) (_tramp_ + 19); \
        (typeof(&$)) ((void *) _tramp_); })

#define _closure_free(_x_)  free(_x_)

#endif      // _CLOSURE_GCC_H_
