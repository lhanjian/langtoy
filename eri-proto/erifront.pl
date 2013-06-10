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

my $builtin_false = { "kind" => "abst", "param" => { "kind" => "param-list", "body" => ["x", "y"] }, 
                      "body" => { "kind" => "expr", 
                                  "body" => { "kind" => "appl", "op" => { "kind" => "ident", "val" => "y" }, 
                                              "arglist" => { "kind" => "arg-list", "body" => [] } } 
                                } 
                    };

my @symlist = ([]);

sub checksym_appl;
sub checksym_abst;
sub checksym_expr;
sub checksym_func;

sub checksym_ident {
    my $sym = $_[0];
    for my $table (@symlist) {
        for my $elt (@$table) {
            if ($sym->{"val"} eq $elt) {
                return $sym;
            }
        }
    }
    { "kind" => "expr", "body" => $builtin_false }
}

sub checksym_abst {
    my $abstref = $_[0];
    my $params = $abstref->{"param"};
    unshift @symlist, $params->{"body"};
    $abstref->{"body"} = checksym_expr($abstref->{"body"});
    shift @symlist;
    $abstref
}

sub checksym_func {
    my $funcref = $_[0];
    my $name = $funcref->{"name"};
    unshift @symlist, [$name];
    $funcref->{"body"} = checksym_abst($funcref->{"body"});
    shift @symlist;
    $funcref
}

sub checksym_expr {
    my $exprref = $_[0];
    switch ($exprref->{"body"}->{"kind"}) {
        case "appl" { $exprref->{"body"} = checksym_appl($exprref->{"body"}); }
        case "abst" { $exprref->{"body"} = checksym_abst($exprref->{"body"}); }
    }
    $exprref
}

sub checksym_appl {
    my $applref = $_[0];
    my ($op, $argl) = ($applref->{"op"}, $applref->{"arglist"});
    my %check_methods = ( "expr" => \&checksym_expr, 
                          "literal" => sub { $_[0] }, 
                          "ident" => \&checksym_ident );
    $applref->{"op"} = $check_methods{$op->{"kind"}}->($op);
    my $args = $argl->{"body"};
    for $elt (@$args) {
        $elt = $check_methods{$elt->{"kind"}}->($elt);
    }
    $argl->{"body"} = $args;
    $applref->{"arglist"} = $argl;
    $applref
}

my $inittbl = $symlist[0];
for my $funcdefn (@$funclist) {
    push @$inittbl, $funcdefn->{"name"};
}

for my $funcelt (@$funclist) {
    $funcelt = checksym_func($funcelt);
}
for my $exprelt (@$exprlist) {
    $exprelt = checksym_expr($exprelt);
}

sub emitabst;
sub emitappl;
sub emitdefn;
sub emitexpr;

sub emitappl {
    my $applref = $_[0];
    my $codefrag = '[ "appl", sub { state $val = undef; state $alist = [ ';
    my %emitterm = ( "ident" => sub { '[ "ident", $'.$_[0]->{"val"}.' ]' },
                     "literal" => sub { '[ "literal", '.$_[0]->{"val"}.' ]' },
                     "expr" => \&emitexpr );
    my $opref = $applref->{"op"};
    my $arglref = $applref->{"arglist"}->{"body"};
    $codefrag .= $emitterm{$opref->{"kind"}}->($opref).", ";
    for my $elt (@$arglref) {
        $codefrag .= $emitterm{$elt->{"kind"}}->($elt).", ";
    }
    $codefrag .= '];';
    $codefrag .= ' if (not $val) { $val = EriIntern::do_apply($alist); } $val } ]';
    $codefrag
}

sub emitexpr {
    my $exprref = $_[0];
    my $codefrag = "";
    switch ($exprref->{"body"}->{"kind"}) {
        case "abst" { $codefrag .= emitabst($exprref->{"body"}); }
        case "appl" { $codefrag .= emitappl($exprref->{"body"}); }
    }
    $codefrag
}

sub emitcurry {
    my $abstref = $_[0];
    my $params = $abstref->{"param"}->{"body"};
    my $nparams = @$params;
    my $c_param = shift @$params;
    my $codefrag = undef;
    if ($nparams) {
        $codefrag .= "sub { my \$$c_param = \$_[0]; ";
    } else {
        $codefrag .= 'sub { ';
    }
    if (@$params) {
        $codefrag .= emitcurry($abstref);
    } else {
        $codefrag .= emitexpr($abstref->{"body"});
    }
    $codefrag.' }'
}

sub emitabst {
    my $abstref = $_[0];
    my $params = $abstref->{"param"}->{"body"};
    my $nparams = @$params;
    '[ "abst", '.$nparams.', '.emitcurry($abstref).' ]'
}

sub emitdefn {
    my $defnref = $_[0];
    'my $'.$defnref->{"name"}.' = '.emitabst($defnref->{"body"}).';';
}

print '#!/usr/bin/env perl', "\n";
print 'use feature "state";', "\n";
print "use EriIntern;\n";

print "# functions: \n";
for my $funcitr (@$funclist) {
    #dumpnode($funcitr);
    print emitdefn($funcitr), "\n";
}
print "# expressions: \n";
for my $expritr (@$exprlist) {
    #dumpnode($expritr);
    print 'print EriIntern::do_eval('.emitexpr($expritr).'), "\n";', "\n";
}
