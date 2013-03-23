#ifndef     _IFEXPR_GCC_H_
#define     _IFEXPR_GCC_H_

#define     if_(...) \
    ( (__VA_ARGS__) ? (
                       // expression or { expression; val; }
#define     else_ \
                      ) : (
                           // expression or { expression; val; }
#define     endif_ \
                         ) )


#endif      // _IFEXPR_GCC_H_
