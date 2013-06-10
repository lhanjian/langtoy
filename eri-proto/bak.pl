#!/usr/bin/env perl

use Parse::Lex;
use Switch;
use EriParser;

my @tokens = (
    qw (
        LPAREN      [\(]
        RPAREN      [\)]
        LAMBDA      [\\\\]
        COLON       [:]
        NUMLITERAL  \d+\.?\d*
        STRLITERAL  \"\.*?\"
        IDENT       [A-Za-z_]+
    )
);

our $lexer = Parse::Lex->new(@tokens);
$lexer->from(\*STDIN);
$lexer->skip('\s+');

sub lexana {
    my $token = $lexer->next;
    if (not $lexer->eoi) {
        return ($token->name, $token->text);
    } else {
        return ('', undef);
    }
}

my $parser = EriParser->new();
$parser->YYParse(yylex => \&lexana);

my $rootref = EriParser::getrootref;
my $indent = 0;

sub putindent {
    for (my $itr = 0; $itr < $indent; $itr++) {
        print "  ";
    }
}

sub dumpexpr {
    my $exprref = $_[0];
    putindent; print "expr: \n";
    ($exprref->{"body"})
}

sub dumpfunc {
    my $funcref = $_[0];
    putindent; print "func: ", $funcref->{"name"}, "\n";
    ($funcref->{"body"})
}

sub dumpabst {
    my $abstref = $_[0];
    putindent; print "abst: ";
    my $paramlist = $abstref->{"param"}->{"body"};
    for my $elt (@$paramlist) {
        print $elt, ' ';
    }
    print "\n";
    ($abstref->{"body"})
}

sub dumpappl {
    my $applref = $_[0];
    putindent; print "appl: \n";
    my $applbody = $applref->{"arglist"}->{"body"};
    ($applref->{"op"}, @$applbody)
}

sub dumpident {
    my $identref = $_[0];
    putindent; print "ident: ", $identref->{"val"}, "\n";
    ()
}

sub dumpliteral {
    my $literalref = $_[0];
    putindent; print "literal: ", $literalref->{"val"}, "\n";
    ()
}

my %dumpmethods = (
    "expr" => \&dumpexpr,
    "func" => \&dumpfunc,
    "abst" => \&dumpabst,
    "appl" => \&dumpappl,
    "ident" => \&dumpident,
    "literal" => \&dumpliteral
);

sub dumpnode {
    $indent++;
    my $node = $_[0];
    my @reslist = $dumpmethods{$node->{"kind"}}->($node);
    for $resnode (@reslist) {
        dumpnode($resnode);
    }
    $indent--;
}

my ($funclist, $exprlist) = ($rootref->{"func"}, $rootref->{"expr"});
print "functions: \n";
for my $funcitr (@$funclist) {
    dumpnode($funcitr);
}
print "expressions: \n";
for my $expritr (@$exprlist) {
    dumpnode($expritr);
}

my @symtab = ( [[], undef] );

sub eval_abst;
sub eval_appl;
sub eval_expr;
sub eval_elt;
sub eval_func;

sub eval_copynode {
    my $noderef = $_[0];
    my %evalnode = %$noderef;
    \%evalnode
}

# Returns the symbol node or builtin false.
sub eval_checksym {
}

sub eval_elt {
    my $elt = $_[0];
    switch ($elt->{"kind"}) {
        case "literal" { return { "kind" => "literal", "val" => $elt->{"val"} }; }
        case "ident" { }
        case "expr" { return eval_expr($elt); }
    }
}

sub eval_expr {
    my $exprref = eval_copynode($_[0]);
    my $ret;
    switch ($exprref->{"body"}->{"kind"}) {
        case "abst" { $ret = eval_abst($exprref->{"body"}); }
        case "appl" { $ret = eval_appl($exprref->{"body"}); }
    }
    $exprref->{"body"} = $ret;
    $ret
}

# An abstraction returns a function object, which replaces the original abstraction node.
# Also we need to keep scopes.
sub eval_abst {
    my $abstref = eval_copynode($_[0]);
    my ($params, $body) = ($abstref->{"param"}, $abstref->{"body"});
    { "kind" => "func", "param" => $params, "body" => $body, "caste" => "user", "args" => undef, "cntx" => {} }
    # TODO iterate through the list and copy outer args into cntx for further use
}

sub eval_appl {
    my $applref = eval_copynode($_[0]);
    my ($op, $args) = ($applref->{"op"}, eval_copynode($applref->{"arglist"}));
    $op = eval_elt($op);
    $applref->{"op"} = $op;
    $applreg->{"arglist"} = $args;
    # Arguments are evaluated when applied to op.
    # op must be a function or an application, i.e, a quoted list.
    switch ($op->{"kind"}) {
        case "appl" { $op = eval_elt($op); $applref->{"op"} = $op; return eval_appl($applref); }
        case "func" {
            my $tmpargs = $args->{"body"};
            my $opparams = $op->{"param"};
            my $nargs = sub { $_[0] < $_[1] ? $_[0] : $_[1] }->(scalar(@$tmpargs), scalar(@$opparams));
            $funcargs = [];
            for (my $itr = 0; $itr < $nargs; $itr++) {
                push @$funcargs, (shift @$tmpargs);
            }
            $op = eval_func($op, $funcargs, $nargs);
            if (@$args == 0) {
                return $op;
            } else {
                $applref->{"op"} = $op;
                return eval_appl($applref);
            }
        }
    }
}

sub eval_func {
    my ($funcref, $arglref, $nargs) = @_;
    my $params = $funcref->{"param"};
    if ($nargs == @$params) {
        # fully apply - 
    } else {
    }
}
