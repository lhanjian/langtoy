#!/usr/bin/perl

sub sum2 {
    $_[0] + $_[1]
}

sub pa {
    my ($f, @a) = @_;
    print $f, "\t", \&sum2, "\n";
    sub { $f->(@a, @_) }
}

print pa(\&sum2, 1)->(2), "\n";
