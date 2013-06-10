####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package EriParser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 1 "eriparser.yp"

    my %prog_root = ( "kind" => "prog", "func" => [], "expr" => [] );
    sub getrootref { \%prog_root }


sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		DEFAULT => -2,
		GOTOS => {
			'form_list' => 2,
			'program' => 1
		}
	},
	{#State 1
		ACTIONS => {
			'' => 3
		}
	},
	{#State 2
		ACTIONS => {
			'LPAREN' => 4,
			'LAMBDA' => 7
		},
		DEFAULT => -1,
		GOTOS => {
			'expr' => 8,
			'func_defn' => 6,
			'form' => 5
		}
	},
	{#State 3
		DEFAULT => 0
	},
	{#State 4
		ACTIONS => {
			'LPAREN' => 4,
			'IDENT' => 13,
			'COLON' => 14,
			'NUMLITERAL' => 9,
			'STRLITERAL' => 11
		},
		GOTOS => {
			'expr' => 12,
			'abstraction' => 10,
			'term' => 16,
			'application' => 15,
			'literal' => 17
		}
	},
	{#State 5
		DEFAULT => -3
	},
	{#State 6
		DEFAULT => -4
	},
	{#State 7
		ACTIONS => {
			'IDENT' => 18
		}
	},
	{#State 8
		DEFAULT => -5
	},
	{#State 9
		DEFAULT => -16
	},
	{#State 10
		ACTIONS => {
			'RPAREN' => 19
		}
	},
	{#State 11
		DEFAULT => -15
	},
	{#State 12
		DEFAULT => -19
	},
	{#State 13
		DEFAULT => -20
	},
	{#State 14
		ACTIONS => {
			'IDENT' => 22
		},
		DEFAULT => -11,
		GOTOS => {
			'ident_list' => 20,
			'param_list' => 21
		}
	},
	{#State 15
		ACTIONS => {
			'RPAREN' => 23
		}
	},
	{#State 16
		ACTIONS => {
			'NUMLITERAL' => 9,
			'STRLITERAL' => 11,
			'IDENT' => 13,
			'LPAREN' => 4
		},
		DEFAULT => -17,
		GOTOS => {
			'expr' => 12,
			'arg_list' => 26,
			'term' => 24,
			'term_list' => 25,
			'literal' => 17
		}
	},
	{#State 17
		DEFAULT => -21
	},
	{#State 18
		ACTIONS => {
			'COLON' => 14
		},
		GOTOS => {
			'abstraction' => 27
		}
	},
	{#State 19
		DEFAULT => -7
	},
	{#State 20
		DEFAULT => -10
	},
	{#State 21
		ACTIONS => {
			'LPAREN' => 4
		},
		GOTOS => {
			'expr' => 28
		}
	},
	{#State 22
		ACTIONS => {
			'IDENT' => 22
		},
		DEFAULT => -11,
		GOTOS => {
			'ident_list' => 29
		}
	},
	{#State 23
		DEFAULT => -8
	},
	{#State 24
		ACTIONS => {
			'LPAREN' => 4,
			'IDENT' => 13,
			'STRLITERAL' => 11,
			'NUMLITERAL' => 9
		},
		DEFAULT => -17,
		GOTOS => {
			'literal' => 17,
			'term_list' => 30,
			'term' => 24,
			'expr' => 12
		}
	},
	{#State 25
		DEFAULT => -14
	},
	{#State 26
		DEFAULT => -13
	},
	{#State 27
		DEFAULT => -6
	},
	{#State 28
		DEFAULT => -9
	},
	{#State 29
		DEFAULT => -12
	},
	{#State 30
		DEFAULT => -18
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'program', 1, undef
	],
	[#Rule 2
		 'form_list', 0, undef
	],
	[#Rule 3
		 'form_list', 2, undef
	],
	[#Rule 4
		 'form', 1,
sub
#line 23 "eriparser.yp"
{ push $prog_root{"func"}, $_[1]; $_[1] }
	],
	[#Rule 5
		 'form', 1,
sub
#line 24 "eriparser.yp"
{ push $prog_root{"expr"}, $_[1]; $_[1] }
	],
	[#Rule 6
		 'func_defn', 3,
sub
#line 27 "eriparser.yp"
{
    my $node = { "kind" => "func", "name" => $_[2], "body" => $_[3] };
    $node
}
	],
	[#Rule 7
		 'expr', 3,
sub
#line 33 "eriparser.yp"
{ my $node = { "kind" => "expr", "body" => $_[2] }; $node }
	],
	[#Rule 8
		 'expr', 3,
sub
#line 34 "eriparser.yp"
{ my $node = { "kind" => "expr", "body" => $_[2] }; $node }
	],
	[#Rule 9
		 'abstraction', 3,
sub
#line 37 "eriparser.yp"
{
    my $node = { "kind" => "abst", "param" => $_[2], "body" => $_[3] };
    $node
}
	],
	[#Rule 10
		 'param_list', 1,
sub
#line 43 "eriparser.yp"
{ 
    my $node = { "kind" => "param-list", "body" => $_[1] };
    $node
}
	],
	[#Rule 11
		 'ident_list', 0,
sub
#line 49 "eriparser.yp"
{ [] }
	],
	[#Rule 12
		 'ident_list', 2,
sub
#line 50 "eriparser.yp"
{ my $sublist = $_[2]; my @list = ($_[1], @$sublist); \@list }
	],
	[#Rule 13
		 'application', 2,
sub
#line 53 "eriparser.yp"
{
    my $node = { "kind" => "appl", "op" => $_[1], "arglist" => $_[2] };
    $node
}
	],
	[#Rule 14
		 'arg_list', 1,
sub
#line 59 "eriparser.yp"
{ my $node = { "kind" => "arg-list", "body" => $_[1] }; $node }
	],
	[#Rule 15
		 'literal', 1, undef
	],
	[#Rule 16
		 'literal', 1, undef
	],
	[#Rule 17
		 'term_list', 0,
sub
#line 64 "eriparser.yp"
{ [] }
	],
	[#Rule 18
		 'term_list', 2,
sub
#line 65 "eriparser.yp"
{ my $sublist = $_[2]; my @list= ($_[1], @$sublist); \@list }
	],
	[#Rule 19
		 'term', 1,
sub
#line 68 "eriparser.yp"
{ $_[1] }
	],
	[#Rule 20
		 'term', 1,
sub
#line 69 "eriparser.yp"
{
    my $node = { "kind" => "ident", "val" => $_[1] };
    $node
}
	],
	[#Rule 21
		 'term', 1,
sub
#line 73 "eriparser.yp"
{
    my $node = { "kind" => "literal", "val" => $_[1] };
    $node
}
	]
],
                                  @_);
    bless($self,$class);
}

#line 79 "eriparser.yp"


1;
