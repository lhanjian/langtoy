#!/usr/bin/env perl
use feature "state";
use EriIntern;
# functions: 
# expressions: 
print EriIntern::do_eval([ "appl", sub { state $val = undef; state $alist = [ [ "abst", 1, sub { my $x = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $x ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } ], [ "abst", 1, sub { my $z = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $z ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } ], [ "literal", 1 ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ]), "\n";
