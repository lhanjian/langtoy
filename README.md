langtoy
=======

Some workarounds. Mainly for C.

##defer-gcc
Syntax sugar for block-scope deferring of function invocations. <br />

##closure-gcc
Weird hacking - closure implementation based on GCC nested function trampolines. <br />
Works under GCC 4.7.2 for Linux on amd64. <br />

##ifexpr-gcc
A simple if-expression using conditional operator and statement expression. <br />
Branch `else_` is necessary for there is no nil type/value in C and there must be a value. <br />
