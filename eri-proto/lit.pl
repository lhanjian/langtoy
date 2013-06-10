#!/usr/bin/env perl
use feature "state";
use EriIntern;
# functions: 
# expressions: 
print EriIntern::do_eval([ "appl", sub { state $val = undef; state $alist = [ [ "literal", 1 ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ]), "\n";
