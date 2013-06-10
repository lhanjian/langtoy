package EriIntern;

use Switch;

sub do_eval;
sub do_apply;

sub do_eval {
    my $interp = $_[0];
    my $retval = undef;
    if (ref($interp) eq "ARRAY") {
        if ($interp->[0] eq "appl") {
            $retval = $interp->[1]->();
        }
    }

    while (ref($retval) eq "ARRAY") {
        $retval = $retval->[1];
    }

    $retval
}

# XXX only op will be evaluated

sub do_apply {
    my $interp = $_[0];
    my $retval = undef;

    my $op = shift @$interp;
    do {
        #print "$op->[0], $op->[1]\n";
        switch ($op->[0]) {
            case "appl" { $op = $op->[1]->(); $retval = $op; }
            case "abst" { 
                my ($nparams, $nargs, $func) = ($op->[1], scalar @$interp, $op->[2]);
                if ($nparams > $nargs) {
                    # partially apply
                    #print "part - $nparams/$nargs\n";
                    while (scalar @$interp) {
                        $func = $func->(shift @$interp);
                    }
                    return [ "abst", $nparams - $nargs, $func ];
                } else {
                    # fully apply
                    #print "full - $nparams\n";
                    if ($nparams == 0) {
                        $retval = $func->();
                        $retval = $retval->[1]->() while (ref($retval) eq "ARRAY" and $retval->[0] eq "appl");
                        return $retval;
                    } else {
                        my $argcnt = $nparams;
                        while ($argcnt) {
                            $func = $func->(shift @$interp);
                            $argcnt--;
                        }
                        while (ref($func) eq "ARRAY" and $func->[0] eq "appl") {
                            $func = $func->[1]->();
                        }
                        ($op, $retval) = ($func, $func);
                    }
                }
            }
            case "ident" { $retval = $op->[1]; $op = $op->[1]; }
            case "literal" { return $op; }
        }
    } while (@$interp);

    $retval
}

1;
