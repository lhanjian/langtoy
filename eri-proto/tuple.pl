#!/usr/bin/env perl
use feature "state";
use EriIntern;
# functions: 
# expressions: 
print EriIntern::do_eval([ "appl", sub { state $val = undef; state $alist = [ [ "abst", 1, sub { my $z = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $z ], [ "literal", 1 ], [ "abst", 1, sub { my $z = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $z ], [ "literal", 2 ], [ "literal", 3 ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } ], [ "abst", 2, sub { my $x = $_[0]; sub { my $y = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $y ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } } ], [ "abst", 2, sub { my $x = $_[0]; sub { my $y = $_[0]; [ "appl", sub { state $val = undef; state $alist = [ [ "ident", $x ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ] } } ], ]; if (not $val) { $val = EriIntern::do_apply($alist); } $val } ]), "\n";
