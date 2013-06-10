#!/usr/bin/env perl

use strict;
use Switch;

my ($linebuf, $rec, $ser, $pos) = ("", 0, 0, 0);
my @sertrans = ('(', ')');
my @recpos = ();

sub rectrans {
    my ($line, $lim, $recp) = @_;
    my $cnt = 0;
    $lim = int($lim / 2);
    while (@{$recp}) {
        my $trpos = shift @{$recp};
        $cnt++;
        if ($cnt <= $lim) {
            substr($$line, $trpos, 1) = '(';
        } else {
            substr($$line, $trpos, 1) = ')';
        }
    }
}

while (my $ch = getc) {
    switch ($ch) {
        case "."    { rectrans \$linebuf, $rec, \@recpos; print $linebuf."\n"; $linebuf = ""; ($pos, $rec, $ser) = (-1, 0, 0); }
        case "\'"   { $linebuf .= $sertrans[$ser]; $ser = 1 - $ser; }
        case "-"    { $linebuf .= $ch; push @recpos, $pos; $rec++; }
        else        { $linebuf .= $ch; }
    }
    $pos++;
}
print $linebuf;
