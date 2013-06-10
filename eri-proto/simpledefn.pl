#!/usr/bin/env perl
use feature "state";
use EriIntern;
# functions: 
my $lc_true = [ "abst", 2, sub { my $x = $_[0]; sub { my $y = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $x ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } } ];
# expressions: 
print EriIntern::do_eval([ "appl", sub { state $val = undef; state $alist = [ [ "ident", $lc_true ], [ "literal", 1 ], [ "literal", 2 ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ]), "\n";
