########################################################################################
#
#    This file was generated using Parse::Eyapp version 1.21.
#
# Copyright © 2006, 2007, 2008, 2009, 2010, 2011, 2012 Casiano Rodriguez-Leon.
# Copyright © 2017 William N. Braswell, Jr.
# All Rights Reserved.
#
# Parse::Yapp is Copyright © 1998, 1999, 2000, 2001, Francois Desarmenien.
# Parse::Yapp is Copyright © 2017 William N. Braswell, Jr.
# All Rights Reserved.
#
#        Don't edit this file, use source file 'Parser.eyp' instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
########################################################################################
package Parse::Easy::Parse::Parser;
use strict;

push @Parse::Easy::Parse::Parser::ISA, 'Parse::Eyapp::Driver';




BEGIN {
  # This strange way to load the modules is to guarantee compatibility when
  # using several standalone and non-standalone Eyapp parsers

  require Parse::Eyapp::Driver unless Parse::Eyapp::Driver->can('YYParse');
  require Parse::Eyapp::Node unless Parse::Eyapp::Node->can('hnew'); 
}
  

sub unexpendedInput { defined($_) ? substr($_, (defined(pos $_) ? pos $_ : 0)) : '' }

#line 11 "Parser.eyp"


  use Parse::Easy::Grammar;
  use Parse::Easy::Rule;
  use Parse::Easy::Term;
  use Parse::Easy::NoTerm;
  use Parse::Easy::CharacterSet;
  use Parse::Easy::Wildcard;
  use Parse::Easy::Control;
  
  my $grammar = Parse::Easy::Grammar->new();
  my $lexer   = $grammar->{lexer};
  my $parser  = $grammar->{parser};
 


# Default lexical analyzer
our $LEX = sub {
    my $self = shift;
    my $pos;

    for (${$self->input}) {
      

      m{\G(\s+)}gc and $self->tokenline($1 =~ tr{\n}{});

      

      /\G(DOT)/gc and return ($1, $1);
      /\G(RBRACE)/gc and return ($1, $1);
      /\G(COLON)/gc and return ($1, $1);
      /\G(LBRACE)/gc and return ($1, $1);
      /\G(LPAREN)/gc and return ($1, $1);
      /\G(SEMICOLON)/gc and return ($1, $1);
      /\G(BAR)/gc and return ($1, $1);
      /\G(COMMA)/gc and return ($1, $1);
      /\G(COLONCOLON)/gc and return ($1, $1);
      /\G(LBRACK)/gc and return ($1, $1);
      /\G(RBRACK)/gc and return ($1, $1);
      /\G(RPAREN)/gc and return ($1, $1);
      /\G(SLASH)/gc and return ($1, $1);
      /\G(GT)/gc and return ($1, $1);
      /\G(LT)/gc and return ($1, $1);
      /\G(STAR)/gc and return ($1, $1);
      /\G(MINUS)/gc and return ($1, $1);
      /\G(QUESTION)/gc and return ($1, $1);
      /\G(PLUS)/gc and return ($1, $1);
      /\G(CIRCUMFLEX)/gc and return ($1, $1);
      /\G(DOLLAR)/gc and return ($1, $1);
      /\G(RANGE)/gc and return ($1, $1);
      /\G(FRAGMENT)/gc and return ($1, $1);
      /\G(QWCLOSE)/gc and return ($1, $1);
      /\G(AS)/gc and return ($1, $1);
      /\G(GRAMMAR)/gc and return ($1, $1);
      /\G(USE)/gc and return ($1, $1);
      /\G(SECTION)/gc and return ($1, $1);
      /\G(QW)/gc and return ($1, $1);
      /\G(TERM)/gc and return ($1, $1);
      /\G(UNDERSCORE)/gc and return ($1, $1);
      /\G(PACKAGE_NAME)/gc and return ($1, $1);
      /\G(NOTERM)/gc and return ($1, $1);
      /\G(SQ_LITERAL)/gc and return ($1, $1);
      /\G(DQ_LITERAL)/gc and return ($1, $1);
      /\G(ACTION)/gc and return ($1, $1);
      /\G(DQRAWSTR)/gc and return ($1, $1);
      /\G(SQRAWSTR)/gc and return ($1, $1);


      return ('', undef) if ($_ eq '') || (defined(pos($_)) && (pos($_) >= length($_)));
      /\G\s*(\S+)/;
      my $near = substr($1,0,10); 

      return($near, $near);

     # die( "Error inside the lexical analyzer near '". $near
     #     ."'. Line: ".$self->line()
     #     .". File: '".$self->YYFilename()."'. No match found.\n");
    }
  }
;


#line 120 Parser.pm

my $warnmessage =<< "EOFWARN";
Warning!: Did you changed the \@Parse::Easy::Parse::Parser::ISA variable inside the header section of the eyapp program?
EOFWARN

sub new {
  my($class)=shift;
  ref($class) and $class=ref($class);

  warn $warnmessage unless __PACKAGE__->isa('Parse::Eyapp::Driver'); 
  my($self)=$class->SUPER::new( 
    yyversion => '1.21',
    yyGRAMMAR  =>
[#[productionNameAndLabel => lhs, [ rhs], bypass]]
  [ '_SUPERSTART' => '$start', [ 'start', '$end' ], 0 ],
  [ 'start_1' => 'start', [ 'program' ], 0 ],
  [ 'program_2' => 'program', [ 'GRAMMAR', 'id', 'SEMICOLON', 'optionalBody' ], 0 ],
  [ 'optionalBody_3' => 'optionalBody', [  ], 0 ],
  [ 'optionalBody_4' => 'optionalBody', [ 'body' ], 0 ],
  [ 'body_5' => 'body', [ 'body', 'spec' ], 0 ],
  [ 'body_6' => 'body', [ 'spec' ], 0 ],
  [ 'spec_7' => 'spec', [ 'rule' ], 0 ],
  [ 'spec_8' => 'spec', [ 'section' ], 0 ],
  [ 'spec_9' => 'spec', [ 'use' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-1', [ 'array' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-1', [  ], 0 ],
  [ 'use_12' => 'use', [ 'USE', 'PACKAGE_NAME', 'OPTIONAL-1', 'SEMICOLON' ], 0 ],
  [ 'array_13' => 'array', [ 'lazyArray' ], 0 ],
  [ 'array_14' => 'array', [ 'legacyArray' ], 0 ],
  [ 'lazyArray_15' => 'lazyArray', [ 'QW', 'qwOpen', 'optLazyItems', 'qwClose' ], 0 ],
  [ 'qwOpen_16' => 'qwOpen', [ 'LPAREN' ], 0 ],
  [ 'qwOpen_17' => 'qwOpen', [ 'SLASH' ], 0 ],
  [ 'qwOpen_18' => 'qwOpen', [ 'LT' ], 0 ],
  [ 'qwClose_19' => 'qwClose', [ 'QWCLOSE' ], 0 ],
  [ 'optLazyItems_20' => 'optLazyItems', [  ], 0 ],
  [ 'optLazyItems_21' => 'optLazyItems', [ 'lazyItems' ], 0 ],
  [ 'lazyItems_22' => 'lazyItems', [ 'lazyItems', 'lazyItem' ], 0 ],
  [ 'lazyItems_23' => 'lazyItems', [ 'lazyItem' ], 0 ],
  [ 'lazyItem_24' => 'lazyItem', [ 'id' ], 0 ],
  [ 'legacyArray_25' => 'legacyArray', [ 'LPAREN', 'optItems', 'RPAREN' ], 0 ],
  [ 'optItems_26' => 'optItems', [  ], 0 ],
  [ 'optItems_27' => 'optItems', [ 'items' ], 0 ],
  [ 'items_28' => 'items', [ 'items', 'COMMA', 'item' ], 0 ],
  [ 'items_29' => 'items', [ 'item' ], 0 ],
  [ 'item_30' => 'item', [ 'id' ], 0 ],
  [ 'item_31' => 'item', [ 'rawStr' ], 0 ],
  [ 'rawStr_32' => 'rawStr', [ 'SQRAWSTR' ], 0 ],
  [ 'rawStr_33' => 'rawStr', [ 'DQRAWSTR' ], 0 ],
  [ 'section_34' => 'section', [ 'SECTION', 'sectionNames', 'SEMICOLON' ], 0 ],
  [ 'sectionNames_35' => 'sectionNames', [ 'sectionName' ], 0 ],
  [ 'sectionNames_36' => 'sectionNames', [ 'LPAREN', 'STAR', 'RPAREN' ], 0 ],
  [ 'sectionNames_37' => 'sectionNames', [ 'LPAREN', 'sectionNameSequence', 'RPAREN' ], 0 ],
  [ 'sectionName_38' => 'sectionName', [ 'TERM' ], 0 ],
  [ 'sectionNameSequence_39' => 'sectionNameSequence', [ 'sectionNameSequence', 'COMMA', 'sectionName' ], 0 ],
  [ 'sectionNameSequence_40' => 'sectionNameSequence', [ 'sectionName' ], 0 ],
  [ 'rule_41' => 'rule', [ 'lexerRule' ], 0 ],
  [ 'rule_42' => 'rule', [ 'parserRule' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-2', [ 'FRAGMENT' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-2', [  ], 0 ],
  [ 'lexerRule_45' => 'lexerRule', [ 'OPTIONAL-2', 'TERM', 'COLON', 'lexerRhss', 'SEMICOLON' ], 0 ],
  [ 'lexerRhss_46' => 'lexerRhss', [ 'lexerRhss', 'BAR', 'lexerRhs' ], 0 ],
  [ 'lexerRhss_47' => 'lexerRhss', [ 'lexerRhs' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-3', [ 'CIRCUMFLEX' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-3', [  ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-4', [ 'DOLLAR' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-4', [  ], 0 ],
  [ 'lexerRhs_52' => 'lexerRhs', [  ], 0 ],
  [ 'lexerRhs_53' => 'lexerRhs', [ 'OPTIONAL-3', 'lexerElements', 'OPTIONAL-4' ], 0 ],
  [ 'lexerElements_54' => 'lexerElements', [ 'lexerElements', 'lexerElement' ], 0 ],
  [ 'lexerElements_55' => 'lexerElements', [ 'lexerElement' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-5', [ 'ebnfSuffix' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-5', [  ], 0 ],
  [ 'lexerElement_58' => 'lexerElement', [ 'lexerAtom', 'OPTIONAL-5' ], 0 ],
  [ 'lexerElement_59' => 'lexerElement', [ 'ACTION' ], 0 ],
  [ 'lexerAtom_60' => 'lexerAtom', [ 'LPAREN', 'lexerRhss', 'RPAREN' ], 0 ],
  [ 'lexerAtom_61' => 'lexerAtom', [ 'RANGE' ], 0 ],
  [ 'lexerAtom_62' => 'lexerAtom', [ 'TERM' ], 0 ],
  [ 'lexerAtom_63' => 'lexerAtom', [ 'DOT' ], 0 ],
  [ 'lexerAtom_64' => 'lexerAtom', [ 'SQ_LITERAL' ], 0 ],
  [ 'lexerAtom_65' => 'lexerAtom', [ 'DQ_LITERAL' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-6', [ 'QUESTION' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-6', [  ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-7', [ 'QUESTION' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-7', [  ], 0 ],
  [ 'ebnfSuffix_70' => 'ebnfSuffix', [ 'PLUS', 'OPTIONAL-6' ], 0 ],
  [ 'ebnfSuffix_71' => 'ebnfSuffix', [ 'STAR', 'OPTIONAL-7' ], 0 ],
  [ 'ebnfSuffix_72' => 'ebnfSuffix', [ 'QUESTION' ], 0 ],
  [ 'parserRule_73' => 'parserRule', [ 'NOTERM', 'parserRuleType', 'COLON', 'parserRhss', 'SEMICOLON' ], 0 ],
  [ 'parserRuleType_74' => 'parserRuleType', [  ], 0 ],
  [ 'parserRuleType_75' => 'parserRuleType', [ 'AS', 'id' ], 0 ],
  [ 'parserRhss_76' => 'parserRhss', [ 'parserRhss', 'BAR', 'parserRhs' ], 0 ],
  [ 'parserRhss_77' => 'parserRhss', [ 'parserRhs' ], 0 ],
  [ 'parserRhs_78' => 'parserRhs', [  ], 0 ],
  [ 'parserRhs_79' => 'parserRhs', [ 'parserElements' ], 0 ],
  [ 'parserElements_80' => 'parserElements', [ 'parserElements', 'parserElement' ], 0 ],
  [ 'parserElements_81' => 'parserElements', [ 'parserElement' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-8', [ 'ebnfSuffix' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-8', [  ], 0 ],
  [ 'parserElement_84' => 'parserElement', [ 'parserAtom', 'OPTIONAL-8' ], 0 ],
  [ 'parserElement_85' => 'parserElement', [ 'ACTION' ], 0 ],
  [ 'parserAtom_86' => 'parserAtom', [ 'LPAREN', 'parserRhss', 'RPAREN' ], 0 ],
  [ 'parserAtom_87' => 'parserAtom', [ 'TERM' ], 0 ],
  [ 'parserAtom_88' => 'parserAtom', [ 'NOTERM' ], 0 ],
  [ 'id_89' => 'id', [ 'TERM' ], 0 ],
  [ 'id_90' => 'id', [ 'NOTERM' ], 0 ],
  [ 'id_91' => 'id', [ 'UNDERSCORE' ], 0 ],
],
    yyLABELS  =>
{
  '_SUPERSTART' => 0,
  'start_1' => 1,
  'program_2' => 2,
  'optionalBody_3' => 3,
  'optionalBody_4' => 4,
  'body_5' => 5,
  'body_6' => 6,
  'spec_7' => 7,
  'spec_8' => 8,
  'spec_9' => 9,
  '_OPTIONAL' => 10,
  '_OPTIONAL' => 11,
  'use_12' => 12,
  'array_13' => 13,
  'array_14' => 14,
  'lazyArray_15' => 15,
  'qwOpen_16' => 16,
  'qwOpen_17' => 17,
  'qwOpen_18' => 18,
  'qwClose_19' => 19,
  'optLazyItems_20' => 20,
  'optLazyItems_21' => 21,
  'lazyItems_22' => 22,
  'lazyItems_23' => 23,
  'lazyItem_24' => 24,
  'legacyArray_25' => 25,
  'optItems_26' => 26,
  'optItems_27' => 27,
  'items_28' => 28,
  'items_29' => 29,
  'item_30' => 30,
  'item_31' => 31,
  'rawStr_32' => 32,
  'rawStr_33' => 33,
  'section_34' => 34,
  'sectionNames_35' => 35,
  'sectionNames_36' => 36,
  'sectionNames_37' => 37,
  'sectionName_38' => 38,
  'sectionNameSequence_39' => 39,
  'sectionNameSequence_40' => 40,
  'rule_41' => 41,
  'rule_42' => 42,
  '_OPTIONAL' => 43,
  '_OPTIONAL' => 44,
  'lexerRule_45' => 45,
  'lexerRhss_46' => 46,
  'lexerRhss_47' => 47,
  '_OPTIONAL' => 48,
  '_OPTIONAL' => 49,
  '_OPTIONAL' => 50,
  '_OPTIONAL' => 51,
  'lexerRhs_52' => 52,
  'lexerRhs_53' => 53,
  'lexerElements_54' => 54,
  'lexerElements_55' => 55,
  '_OPTIONAL' => 56,
  '_OPTIONAL' => 57,
  'lexerElement_58' => 58,
  'lexerElement_59' => 59,
  'lexerAtom_60' => 60,
  'lexerAtom_61' => 61,
  'lexerAtom_62' => 62,
  'lexerAtom_63' => 63,
  'lexerAtom_64' => 64,
  'lexerAtom_65' => 65,
  '_OPTIONAL' => 66,
  '_OPTIONAL' => 67,
  '_OPTIONAL' => 68,
  '_OPTIONAL' => 69,
  'ebnfSuffix_70' => 70,
  'ebnfSuffix_71' => 71,
  'ebnfSuffix_72' => 72,
  'parserRule_73' => 73,
  'parserRuleType_74' => 74,
  'parserRuleType_75' => 75,
  'parserRhss_76' => 76,
  'parserRhss_77' => 77,
  'parserRhs_78' => 78,
  'parserRhs_79' => 79,
  'parserElements_80' => 80,
  'parserElements_81' => 81,
  '_OPTIONAL' => 82,
  '_OPTIONAL' => 83,
  'parserElement_84' => 84,
  'parserElement_85' => 85,
  'parserAtom_86' => 86,
  'parserAtom_87' => 87,
  'parserAtom_88' => 88,
  'id_89' => 89,
  'id_90' => 90,
  'id_91' => 91,
},
    yyTERMS  =>
{ '' => { ISSEMANTIC => 0 },
	ACTION => { ISSEMANTIC => 1 },
	AS => { ISSEMANTIC => 1 },
	BAR => { ISSEMANTIC => 1 },
	CIRCUMFLEX => { ISSEMANTIC => 1 },
	COLON => { ISSEMANTIC => 1 },
	COMMA => { ISSEMANTIC => 1 },
	DOLLAR => { ISSEMANTIC => 1 },
	DOT => { ISSEMANTIC => 1 },
	DQRAWSTR => { ISSEMANTIC => 1 },
	DQ_LITERAL => { ISSEMANTIC => 1 },
	FRAGMENT => { ISSEMANTIC => 1 },
	GRAMMAR => { ISSEMANTIC => 1 },
	LPAREN => { ISSEMANTIC => 1 },
	LT => { ISSEMANTIC => 1 },
	NOTERM => { ISSEMANTIC => 1 },
	PACKAGE_NAME => { ISSEMANTIC => 1 },
	PLUS => { ISSEMANTIC => 1 },
	QUESTION => { ISSEMANTIC => 1 },
	QW => { ISSEMANTIC => 1 },
	QWCLOSE => { ISSEMANTIC => 1 },
	RANGE => { ISSEMANTIC => 1 },
	RPAREN => { ISSEMANTIC => 1 },
	SECTION => { ISSEMANTIC => 1 },
	SEMICOLON => { ISSEMANTIC => 1 },
	SLASH => { ISSEMANTIC => 1 },
	SQRAWSTR => { ISSEMANTIC => 1 },
	SQ_LITERAL => { ISSEMANTIC => 1 },
	STAR => { ISSEMANTIC => 1 },
	TERM => { ISSEMANTIC => 1 },
	UNDERSCORE => { ISSEMANTIC => 1 },
	USE => { ISSEMANTIC => 1 },
	error => { ISSEMANTIC => 0 },
},
    yyFILENAME  => 'Parser.eyp',
    yystates =>
[
	{#State 0
		ACTIONS => {
			'GRAMMAR' => 2
		},
		GOTOS => {
			'program' => 3,
			'start' => 1
		}
	},
	{#State 1
		ACTIONS => {
			'' => 4
		}
	},
	{#State 2
		ACTIONS => {
			'UNDERSCORE' => 6,
			'NOTERM' => 7,
			'TERM' => 5
		},
		GOTOS => {
			'id' => 8
		}
	},
	{#State 3
		DEFAULT => -1
	},
	{#State 4
		DEFAULT => 0
	},
	{#State 5
		DEFAULT => -89
	},
	{#State 6
		DEFAULT => -91
	},
	{#State 7
		DEFAULT => -90
	},
	{#State 8
		ACTIONS => {
			'SEMICOLON' => 9
		}
	},
	{#State 9
		ACTIONS => {
			'USE' => 12,
			'SECTION' => 13,
			'NOTERM' => 19,
			'' => -3,
			'TERM' => -44,
			'FRAGMENT' => 15
		},
		GOTOS => {
			'rule' => 14,
			'spec' => 16,
			'optionalBody' => 11,
			'OPTIONAL-2' => 10,
			'section' => 22,
			'body' => 21,
			'use' => 20,
			'lexerRule' => 17,
			'parserRule' => 18
		}
	},
	{#State 10
		ACTIONS => {
			'TERM' => 23
		}
	},
	{#State 11
		DEFAULT => -2
	},
	{#State 12
		ACTIONS => {
			'PACKAGE_NAME' => 24
		}
	},
	{#State 13
		ACTIONS => {
			'LPAREN' => 25,
			'TERM' => 28
		},
		GOTOS => {
			'sectionName' => 26,
			'sectionNames' => 27
		}
	},
	{#State 14
		DEFAULT => -7
	},
	{#State 15
		DEFAULT => -43
	},
	{#State 16
		DEFAULT => -6
	},
	{#State 17
		DEFAULT => -41
	},
	{#State 18
		DEFAULT => -42
	},
	{#State 19
		ACTIONS => {
			'COLON' => -74,
			'AS' => 30
		},
		GOTOS => {
			'parserRuleType' => 29
		}
	},
	{#State 20
		DEFAULT => -9
	},
	{#State 21
		ACTIONS => {
			'SECTION' => 13,
			'USE' => 12,
			'NOTERM' => 19,
			'' => -4,
			'TERM' => -44,
			'FRAGMENT' => 15
		},
		GOTOS => {
			'use' => 20,
			'parserRule' => 18,
			'lexerRule' => 17,
			'OPTIONAL-2' => 10,
			'spec' => 31,
			'rule' => 14,
			'section' => 22
		}
	},
	{#State 22
		DEFAULT => -8
	},
	{#State 23
		ACTIONS => {
			'COLON' => 32
		}
	},
	{#State 24
		ACTIONS => {
			'LPAREN' => 35,
			'QW' => 33,
			'SEMICOLON' => -11
		},
		GOTOS => {
			'legacyArray' => 38,
			'lazyArray' => 34,
			'OPTIONAL-1' => 36,
			'array' => 37
		}
	},
	{#State 25
		ACTIONS => {
			'TERM' => 28,
			'STAR' => 39
		},
		GOTOS => {
			'sectionNameSequence' => 41,
			'sectionName' => 40
		}
	},
	{#State 26
		DEFAULT => -35
	},
	{#State 27
		ACTIONS => {
			'SEMICOLON' => 42
		}
	},
	{#State 28
		DEFAULT => -38
	},
	{#State 29
		ACTIONS => {
			'COLON' => 43
		}
	},
	{#State 30
		ACTIONS => {
			'TERM' => 5,
			'NOTERM' => 7,
			'UNDERSCORE' => 6
		},
		GOTOS => {
			'id' => 44
		}
	},
	{#State 31
		DEFAULT => -5
	},
	{#State 32
		ACTIONS => {
			'TERM' => -49,
			'ACTION' => -49,
			'BAR' => -52,
			'SEMICOLON' => -52,
			'DOT' => -49,
			'DQ_LITERAL' => -49,
			'LPAREN' => -49,
			'RANGE' => -49,
			'SQ_LITERAL' => -49,
			'CIRCUMFLEX' => 47
		},
		GOTOS => {
			'lexerRhss' => 45,
			'OPTIONAL-3' => 48,
			'lexerRhs' => 46
		}
	},
	{#State 33
		ACTIONS => {
			'SLASH' => 49,
			'LT' => 51,
			'LPAREN' => 50
		},
		GOTOS => {
			'qwOpen' => 52
		}
	},
	{#State 34
		DEFAULT => -13
	},
	{#State 35
		ACTIONS => {
			'RPAREN' => -26,
			'TERM' => 5,
			'DQRAWSTR' => 58,
			'SQRAWSTR' => 56,
			'UNDERSCORE' => 6,
			'NOTERM' => 7
		},
		GOTOS => {
			'id' => 55,
			'item' => 54,
			'rawStr' => 53,
			'items' => 59,
			'optItems' => 57
		}
	},
	{#State 36
		ACTIONS => {
			'SEMICOLON' => 60
		}
	},
	{#State 37
		DEFAULT => -10
	},
	{#State 38
		DEFAULT => -14
	},
	{#State 39
		ACTIONS => {
			'RPAREN' => 61
		}
	},
	{#State 40
		DEFAULT => -40
	},
	{#State 41
		ACTIONS => {
			'RPAREN' => 63,
			'COMMA' => 62
		}
	},
	{#State 42
		DEFAULT => -34
	},
	{#State 43
		ACTIONS => {
			'ACTION' => 69,
			'TERM' => 71,
			'BAR' => -78,
			'SEMICOLON' => -78,
			'NOTERM' => 64,
			'LPAREN' => 67
		},
		GOTOS => {
			'parserAtom' => 68,
			'parserRhss' => 72,
			'parserRhs' => 66,
			'parserElements' => 65,
			'parserElement' => 70
		}
	},
	{#State 44
		DEFAULT => -75
	},
	{#State 45
		ACTIONS => {
			'SEMICOLON' => 73,
			'BAR' => 74
		}
	},
	{#State 46
		DEFAULT => -47
	},
	{#State 47
		DEFAULT => -48
	},
	{#State 48
		ACTIONS => {
			'LPAREN' => 82,
			'SQ_LITERAL' => 84,
			'RANGE' => 83,
			'DQ_LITERAL' => 80,
			'TERM' => 75,
			'ACTION' => 77,
			'DOT' => 81
		},
		GOTOS => {
			'lexerAtom' => 79,
			'lexerElements' => 78,
			'lexerElement' => 76
		}
	},
	{#State 49
		DEFAULT => -17
	},
	{#State 50
		DEFAULT => -16
	},
	{#State 51
		DEFAULT => -18
	},
	{#State 52
		ACTIONS => {
			'UNDERSCORE' => 6,
			'NOTERM' => 7,
			'TERM' => 5,
			'QWCLOSE' => -20
		},
		GOTOS => {
			'optLazyItems' => 86,
			'lazyItems' => 87,
			'lazyItem' => 88,
			'id' => 85
		}
	},
	{#State 53
		DEFAULT => -31
	},
	{#State 54
		DEFAULT => -29
	},
	{#State 55
		DEFAULT => -30
	},
	{#State 56
		DEFAULT => -32
	},
	{#State 57
		ACTIONS => {
			'RPAREN' => 89
		}
	},
	{#State 58
		DEFAULT => -33
	},
	{#State 59
		ACTIONS => {
			'RPAREN' => -27,
			'COMMA' => 90
		}
	},
	{#State 60
		DEFAULT => -12
	},
	{#State 61
		DEFAULT => -36
	},
	{#State 62
		ACTIONS => {
			'TERM' => 28
		},
		GOTOS => {
			'sectionName' => 91
		}
	},
	{#State 63
		DEFAULT => -37
	},
	{#State 64
		DEFAULT => -88
	},
	{#State 65
		ACTIONS => {
			'NOTERM' => 64,
			'LPAREN' => 67,
			'ACTION' => 69,
			'TERM' => 71,
			'SEMICOLON' => -79,
			'BAR' => -79,
			'RPAREN' => -79
		},
		GOTOS => {
			'parserAtom' => 68,
			'parserElement' => 92
		}
	},
	{#State 66
		DEFAULT => -77
	},
	{#State 67
		ACTIONS => {
			'RPAREN' => -78,
			'LPAREN' => 67,
			'BAR' => -78,
			'NOTERM' => 64,
			'ACTION' => 69,
			'TERM' => 71
		},
		GOTOS => {
			'parserElement' => 70,
			'parserAtom' => 68,
			'parserRhss' => 93,
			'parserRhs' => 66,
			'parserElements' => 65
		}
	},
	{#State 68
		ACTIONS => {
			'TERM' => -83,
			'ACTION' => -83,
			'BAR' => -83,
			'SEMICOLON' => -83,
			'QUESTION' => 94,
			'RPAREN' => -83,
			'PLUS' => 95,
			'NOTERM' => -83,
			'LPAREN' => -83,
			'STAR' => 97
		},
		GOTOS => {
			'ebnfSuffix' => 96,
			'OPTIONAL-8' => 98
		}
	},
	{#State 69
		DEFAULT => -85
	},
	{#State 70
		DEFAULT => -81
	},
	{#State 71
		DEFAULT => -87
	},
	{#State 72
		ACTIONS => {
			'SEMICOLON' => 99,
			'BAR' => 100
		}
	},
	{#State 73
		DEFAULT => -45
	},
	{#State 74
		ACTIONS => {
			'SEMICOLON' => -52,
			'BAR' => -52,
			'ACTION' => -49,
			'TERM' => -49,
			'RPAREN' => -52,
			'DQ_LITERAL' => -49,
			'DOT' => -49,
			'CIRCUMFLEX' => 47,
			'SQ_LITERAL' => -49,
			'RANGE' => -49,
			'LPAREN' => -49
		},
		GOTOS => {
			'lexerRhs' => 101,
			'OPTIONAL-3' => 48
		}
	},
	{#State 75
		DEFAULT => -62
	},
	{#State 76
		DEFAULT => -55
	},
	{#State 77
		DEFAULT => -59
	},
	{#State 78
		ACTIONS => {
			'DOT' => 81,
			'DQ_LITERAL' => 80,
			'SQ_LITERAL' => 84,
			'DOLLAR' => 104,
			'RANGE' => 83,
			'LPAREN' => 82,
			'ACTION' => 77,
			'TERM' => 75,
			'BAR' => -51,
			'SEMICOLON' => -51,
			'RPAREN' => -51
		},
		GOTOS => {
			'lexerAtom' => 79,
			'OPTIONAL-4' => 102,
			'lexerElement' => 103
		}
	},
	{#State 79
		ACTIONS => {
			'LPAREN' => -57,
			'DOLLAR' => -57,
			'SQ_LITERAL' => -57,
			'RANGE' => -57,
			'STAR' => 97,
			'DOT' => -57,
			'DQ_LITERAL' => -57,
			'RPAREN' => -57,
			'PLUS' => 95,
			'TERM' => -57,
			'ACTION' => -57,
			'BAR' => -57,
			'SEMICOLON' => -57,
			'QUESTION' => 94
		},
		GOTOS => {
			'OPTIONAL-5' => 106,
			'ebnfSuffix' => 105
		}
	},
	{#State 80
		DEFAULT => -65
	},
	{#State 81
		DEFAULT => -63
	},
	{#State 82
		ACTIONS => {
			'DQ_LITERAL' => -49,
			'DOT' => -49,
			'CIRCUMFLEX' => 47,
			'LPAREN' => -49,
			'RANGE' => -49,
			'SQ_LITERAL' => -49,
			'BAR' => -52,
			'TERM' => -49,
			'ACTION' => -49,
			'RPAREN' => -52
		},
		GOTOS => {
			'lexerRhs' => 46,
			'lexerRhss' => 107,
			'OPTIONAL-3' => 48
		}
	},
	{#State 83
		DEFAULT => -61
	},
	{#State 84
		DEFAULT => -64
	},
	{#State 85
		DEFAULT => -24
	},
	{#State 86
		ACTIONS => {
			'QWCLOSE' => 108
		},
		GOTOS => {
			'qwClose' => 109
		}
	},
	{#State 87
		ACTIONS => {
			'NOTERM' => 7,
			'UNDERSCORE' => 6,
			'TERM' => 5,
			'QWCLOSE' => -21
		},
		GOTOS => {
			'id' => 85,
			'lazyItem' => 110
		}
	},
	{#State 88
		DEFAULT => -23
	},
	{#State 89
		DEFAULT => -25
	},
	{#State 90
		ACTIONS => {
			'SQRAWSTR' => 56,
			'UNDERSCORE' => 6,
			'NOTERM' => 7,
			'DQRAWSTR' => 58,
			'TERM' => 5
		},
		GOTOS => {
			'item' => 111,
			'rawStr' => 53,
			'id' => 55
		}
	},
	{#State 91
		DEFAULT => -39
	},
	{#State 92
		DEFAULT => -80
	},
	{#State 93
		ACTIONS => {
			'RPAREN' => 112,
			'BAR' => 100
		}
	},
	{#State 94
		DEFAULT => -72
	},
	{#State 95
		ACTIONS => {
			'RPAREN' => -67,
			'QUESTION' => 113,
			'BAR' => -67,
			'SEMICOLON' => -67,
			'TERM' => -67,
			'ACTION' => -67,
			'LPAREN' => -67,
			'SQ_LITERAL' => -67,
			'DOLLAR' => -67,
			'RANGE' => -67,
			'DQ_LITERAL' => -67,
			'NOTERM' => -67,
			'DOT' => -67
		},
		GOTOS => {
			'OPTIONAL-6' => 114
		}
	},
	{#State 96
		DEFAULT => -82
	},
	{#State 97
		ACTIONS => {
			'QUESTION' => 116,
			'BAR' => -69,
			'SEMICOLON' => -69,
			'ACTION' => -69,
			'TERM' => -69,
			'RPAREN' => -69,
			'DQ_LITERAL' => -69,
			'NOTERM' => -69,
			'DOT' => -69,
			'SQ_LITERAL' => -69,
			'RANGE' => -69,
			'DOLLAR' => -69,
			'LPAREN' => -69
		},
		GOTOS => {
			'OPTIONAL-7' => 115
		}
	},
	{#State 98
		DEFAULT => -84
	},
	{#State 99
		DEFAULT => -73
	},
	{#State 100
		ACTIONS => {
			'RPAREN' => -78,
			'TERM' => 71,
			'ACTION' => 69,
			'SEMICOLON' => -78,
			'BAR' => -78,
			'LPAREN' => 67,
			'NOTERM' => 64
		},
		GOTOS => {
			'parserElement' => 70,
			'parserRhs' => 117,
			'parserElements' => 65,
			'parserAtom' => 68
		}
	},
	{#State 101
		DEFAULT => -46
	},
	{#State 102
		DEFAULT => -53
	},
	{#State 103
		DEFAULT => -54
	},
	{#State 104
		DEFAULT => -50
	},
	{#State 105
		DEFAULT => -56
	},
	{#State 106
		DEFAULT => -58
	},
	{#State 107
		ACTIONS => {
			'RPAREN' => 118,
			'BAR' => 74
		}
	},
	{#State 108
		DEFAULT => -19
	},
	{#State 109
		DEFAULT => -15
	},
	{#State 110
		DEFAULT => -22
	},
	{#State 111
		DEFAULT => -28
	},
	{#State 112
		DEFAULT => -86
	},
	{#State 113
		DEFAULT => -66
	},
	{#State 114
		DEFAULT => -70
	},
	{#State 115
		DEFAULT => -71
	},
	{#State 116
		DEFAULT => -68
	},
	{#State 117
		DEFAULT => -76
	},
	{#State 118
		DEFAULT => -60
	}
],
    yyrules  =>
[
	[#Rule _SUPERSTART
		 '$start', 2, undef
#line 1107 Parser.pm
	],
	[#Rule start_1
		 'start', 1, undef
#line 1111 Parser.pm
	],
	[#Rule program_2
		 'program', 4,
sub {
#line 37 "Parser.eyp"

    $grammar->{name} = $_[2];
    $grammar;
  }
#line 1121 Parser.pm
	],
	[#Rule optionalBody_3
		 'optionalBody', 0, undef
#line 1125 Parser.pm
	],
	[#Rule optionalBody_4
		 'optionalBody', 1, undef
#line 1129 Parser.pm
	],
	[#Rule body_5
		 'body', 2, undef
#line 1133 Parser.pm
	],
	[#Rule body_6
		 'body', 1, undef
#line 1137 Parser.pm
	],
	[#Rule spec_7
		 'spec', 1, undef
#line 1141 Parser.pm
	],
	[#Rule spec_8
		 'spec', 1, undef
#line 1145 Parser.pm
	],
	[#Rule spec_9
		 'spec', 1, undef
#line 1149 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-1', 1,
sub {
#line 60 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1156 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-1', 0,
sub {
#line 60 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1163 Parser.pm
	],
	[#Rule use_12
		 'use', 4,
sub {
#line 61 "Parser.eyp"

    my $array = $_[3][0] // [];
    $grammar->processUse($_[2], $array);
  }
#line 1173 Parser.pm
	],
	[#Rule array_13
		 'array', 1, undef
#line 1177 Parser.pm
	],
	[#Rule array_14
		 'array', 1, undef
#line 1181 Parser.pm
	],
	[#Rule lazyArray_15
		 'lazyArray', 4,
sub {
#line 73 "Parser.eyp"
 $_[3] // [] }
#line 1188 Parser.pm
	],
	[#Rule qwOpen_16
		 'qwOpen', 1, undef
#line 1192 Parser.pm
	],
	[#Rule qwOpen_17
		 'qwOpen', 1, undef
#line 1196 Parser.pm
	],
	[#Rule qwOpen_18
		 'qwOpen', 1, undef
#line 1200 Parser.pm
	],
	[#Rule qwClose_19
		 'qwClose', 1, undef
#line 1204 Parser.pm
	],
	[#Rule optLazyItems_20
		 'optLazyItems', 0, undef
#line 1208 Parser.pm
	],
	[#Rule optLazyItems_21
		 'optLazyItems', 1, undef
#line 1212 Parser.pm
	],
	[#Rule lazyItems_22
		 'lazyItems', 2,
sub {
#line 92 "Parser.eyp"
 push @{$_[1]}, $_[2]; $_[1] }
#line 1219 Parser.pm
	],
	[#Rule lazyItems_23
		 'lazyItems', 1,
sub {
#line 93 "Parser.eyp"
 [$_[1]] }
#line 1226 Parser.pm
	],
	[#Rule lazyItem_24
		 'lazyItem', 1, undef
#line 1230 Parser.pm
	],
	[#Rule legacyArray_25
		 'legacyArray', 3,
sub {
#line 101 "Parser.eyp"
 $_[2] // [] }
#line 1237 Parser.pm
	],
	[#Rule optItems_26
		 'optItems', 0, undef
#line 1241 Parser.pm
	],
	[#Rule optItems_27
		 'optItems', 1, undef
#line 1245 Parser.pm
	],
	[#Rule items_28
		 'items', 3,
sub {
#line 110 "Parser.eyp"
 push @{$_[1]}, $_[3]; $_[1] }
#line 1252 Parser.pm
	],
	[#Rule items_29
		 'items', 1,
sub {
#line 111 "Parser.eyp"
 [$_[1]] }
#line 1259 Parser.pm
	],
	[#Rule item_30
		 'item', 1, undef
#line 1263 Parser.pm
	],
	[#Rule item_31
		 'item', 1, undef
#line 1267 Parser.pm
	],
	[#Rule rawStr_32
		 'rawStr', 1, undef
#line 1271 Parser.pm
	],
	[#Rule rawStr_33
		 'rawStr', 1, undef
#line 1275 Parser.pm
	],
	[#Rule section_34
		 'section', 3,
sub {
#line 126 "Parser.eyp"
 $lexer->currentSections($_[2]) }
#line 1282 Parser.pm
	],
	[#Rule sectionNames_35
		 'sectionNames', 1,
sub {
#line 130 "Parser.eyp"
 [$_[1]] }
#line 1289 Parser.pm
	],
	[#Rule sectionNames_36
		 'sectionNames', 3,
sub {
#line 131 "Parser.eyp"
 $lexer->{sections} }
#line 1296 Parser.pm
	],
	[#Rule sectionNames_37
		 'sectionNames', 3,
sub {
#line 132 "Parser.eyp"
 $_[2]   }
#line 1303 Parser.pm
	],
	[#Rule sectionName_38
		 'sectionName', 1, undef
#line 1307 Parser.pm
	],
	[#Rule sectionNameSequence_39
		 'sectionNameSequence', 3,
sub {
#line 140 "Parser.eyp"
 push @{$_[1]}, $_[3]; $_[1] }
#line 1314 Parser.pm
	],
	[#Rule sectionNameSequence_40
		 'sectionNameSequence', 1,
sub {
#line 141 "Parser.eyp"
 [$_[1]] }
#line 1321 Parser.pm
	],
	[#Rule rule_41
		 'rule', 1, undef
#line 1325 Parser.pm
	],
	[#Rule rule_42
		 'rule', 1, undef
#line 1329 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-2', 1,
sub {
#line 150 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1336 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-2', 0,
sub {
#line 150 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1343 Parser.pm
	],
	[#Rule lexerRule_45
		 'lexerRule', 5,
sub {
#line 151 "Parser.eyp"

    my $name     = $_[2];
  	my $fragment = defined $_[1][0];
  	exists $lexer->{names}->{$name} || exists $parser->{names}->{$name}
  	and die sprintf "rule '%s' already declared.", $name;
  	foreach my $rhs(@{ $_[4] }){
  	    my $rule = Parse::Easy::Rule->new($name, $rhs);
  	    $fragment and $rule->fragment(1);
  	    $lexer->addRule($rule);
  	} 
  }
#line 1360 Parser.pm
	],
	[#Rule lexerRhss_46
		 'lexerRhss', 3,
sub {
#line 165 "Parser.eyp"
 push @{$_[1]}, $_[3]; $_[1] }
#line 1367 Parser.pm
	],
	[#Rule lexerRhss_47
		 'lexerRhss', 1,
sub {
#line 166 "Parser.eyp"
 [$_[1]] }
#line 1374 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-3', 1,
sub {
#line 171 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1381 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-3', 0,
sub {
#line 171 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1388 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-4', 1,
sub {
#line 171 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1395 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-4', 0,
sub {
#line 171 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1402 Parser.pm
	],
	[#Rule lexerRhs_52
		 'lexerRhs', 0, undef
#line 1406 Parser.pm
	],
	[#Rule lexerRhs_53
		 'lexerRhs', 3,
sub {
#line 172 "Parser.eyp"

  	if (!( defined $_[1][0] || defined $_[3][0] ) ) {
  		$_[2];
  	}
  	else {
  		my @elements = ();
  		defined $_[1][0] and push @elements, Parse::Easy::Control->new('START');
  		push @elements, @{ $_[2] };
  		defined $_[3][0] and push @elements, Parse::Easy::Control->new('END');
  		\@elements;
  	}
  }
#line 1424 Parser.pm
	],
	[#Rule lexerElements_54
		 'lexerElements', 2,
sub {
#line 187 "Parser.eyp"
 push @{$_[1]}, $_[2]; $_[1] }
#line 1431 Parser.pm
	],
	[#Rule lexerElements_55
		 'lexerElements', 1,
sub {
#line 188 "Parser.eyp"
 [ $_[1] ]                   }
#line 1438 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-5', 1,
sub {
#line 192 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1445 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-5', 0,
sub {
#line 192 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1452 Parser.pm
	],
	[#Rule lexerElement_58
		 'lexerElement', 2,
sub {
#line 193 "Parser.eyp"

    my $ebnf = $_[2][0];
    if($ebnf){
      $lexer->ebnf($_[1], $ebnf);
    }else{
      $_[1];
    }
  }
#line 1466 Parser.pm
	],
	[#Rule lexerElement_59
		 'lexerElement', 1, undef
#line 1470 Parser.pm
	],
	[#Rule lexerAtom_60
		 'lexerAtom', 3,
sub {
#line 205 "Parser.eyp"
 $lexer->parenthesis($_[2])  }
#line 1477 Parser.pm
	],
	[#Rule lexerAtom_61
		 'lexerAtom', 1,
sub {
#line 206 "Parser.eyp"
 Parse::Easy::CharacterSet->new($_[1])}
#line 1484 Parser.pm
	],
	[#Rule lexerAtom_62
		 'lexerAtom', 1,
sub {
#line 207 "Parser.eyp"
 Parse::Easy::NoTerm->new($_[1])      }
#line 1491 Parser.pm
	],
	[#Rule lexerAtom_63
		 'lexerAtom', 1,
sub {
#line 208 "Parser.eyp"
 Parse::Easy::CharacterSet->new(
                     Parse::Easy::Wildcard::wildcard())   }
#line 1499 Parser.pm
	],
	[#Rule lexerAtom_64
		 'lexerAtom', 1, undef
#line 1503 Parser.pm
	],
	[#Rule lexerAtom_65
		 'lexerAtom', 1, undef
#line 1507 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-6', 1,
sub {
#line 215 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1514 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-6', 0,
sub {
#line 215 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1521 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-7', 1,
sub {
#line 216 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1528 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-7', 0,
sub {
#line 216 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1535 Parser.pm
	],
	[#Rule ebnfSuffix_70
		 'ebnfSuffix', 2,
sub {
#line 215 "Parser.eyp"
 0x01 | ( defined $_[2][0] ? 0x10 : 0x00 ) }
#line 1542 Parser.pm
	],
	[#Rule ebnfSuffix_71
		 'ebnfSuffix', 2,
sub {
#line 216 "Parser.eyp"
 0x02 | ( defined $_[2][0] ? 0x10 : 0x00 ) }
#line 1549 Parser.pm
	],
	[#Rule ebnfSuffix_72
		 'ebnfSuffix', 1,
sub {
#line 217 "Parser.eyp"
 0x04                                      }
#line 1556 Parser.pm
	],
	[#Rule parserRule_73
		 'parserRule', 5,
sub {
#line 225 "Parser.eyp"

    my $name     = $_[1];
  	exists $lexer->{names}->{$name} || exists $parser->{names}->{$name}
  	and die sprintf "rule '%s' already declared.", $name;
  	foreach my $rhs(@{ $_[4] }){
  	    my $rule = Parse::Easy::Rule->new($name, $rhs);
  	    $rule->returnType($_[2]);
  	    $parser->addRule($rule);
  	} 
  }
#line 1572 Parser.pm
	],
	[#Rule parserRuleType_74
		 'parserRuleType', 0,
sub {
#line 238 "Parser.eyp"
 undef }
#line 1579 Parser.pm
	],
	[#Rule parserRuleType_75
		 'parserRuleType', 2,
sub {
#line 239 "Parser.eyp"
 $_[2] }
#line 1586 Parser.pm
	],
	[#Rule parserRhss_76
		 'parserRhss', 3,
sub {
#line 243 "Parser.eyp"
 push @{$_[1]}, $_[3]; $_[1] }
#line 1593 Parser.pm
	],
	[#Rule parserRhss_77
		 'parserRhss', 1,
sub {
#line 244 "Parser.eyp"
 [$_[1]] }
#line 1600 Parser.pm
	],
	[#Rule parserRhs_78
		 'parserRhs', 0,
sub {
#line 248 "Parser.eyp"
 [] }
#line 1607 Parser.pm
	],
	[#Rule parserRhs_79
		 'parserRhs', 1, undef
#line 1611 Parser.pm
	],
	[#Rule parserElements_80
		 'parserElements', 2,
sub {
#line 253 "Parser.eyp"
 push @{$_[1]}, $_[2]; $_[1] }
#line 1618 Parser.pm
	],
	[#Rule parserElements_81
		 'parserElements', 1,
sub {
#line 254 "Parser.eyp"
 [ $_[1] ]                   }
#line 1625 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-8', 1,
sub {
#line 258 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 1632 Parser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-8', 0,
sub {
#line 258 "Parser.eyp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 1639 Parser.pm
	],
	[#Rule parserElement_84
		 'parserElement', 2,
sub {
#line 259 "Parser.eyp"

    my $ebnf = $_[2][0];
    if($ebnf){
      $parser->ebnf($_[1], $ebnf);
    }else{
      $_[1];
    }
  }
#line 1653 Parser.pm
	],
	[#Rule parserElement_85
		 'parserElement', 1, undef
#line 1657 Parser.pm
	],
	[#Rule parserAtom_86
		 'parserAtom', 3,
sub {
#line 271 "Parser.eyp"
 $parser->parenthesis($_[2])  }
#line 1664 Parser.pm
	],
	[#Rule parserAtom_87
		 'parserAtom', 1,
sub {
#line 272 "Parser.eyp"
 Parse::Easy::Term->new($_[1])   }
#line 1671 Parser.pm
	],
	[#Rule parserAtom_88
		 'parserAtom', 1,
sub {
#line 273 "Parser.eyp"
 Parse::Easy::NoTerm->new($_[1]) }
#line 1678 Parser.pm
	],
	[#Rule id_89
		 'id', 1, undef
#line 1682 Parser.pm
	],
	[#Rule id_90
		 'id', 1, undef
#line 1686 Parser.pm
	],
	[#Rule id_91
		 'id', 1, undef
#line 1690 Parser.pm
	]
],
#line 1693 Parser.pm
    yybypass       => 0,
    yybuildingtree => 0,
    yyprefix       => '',
    yyaccessors    => {
   },
    yyconflicthandlers => {}
,
    yystateconflict => {  },
    @_,
  );
  bless($self,$class);

  $self->make_node_classes('TERMINAL', '_OPTIONAL', '_STAR_LIST', '_PLUS_LIST', 
         '_SUPERSTART', 
         'start_1', 
         'program_2', 
         'optionalBody_3', 
         'optionalBody_4', 
         'body_5', 
         'body_6', 
         'spec_7', 
         'spec_8', 
         'spec_9', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'use_12', 
         'array_13', 
         'array_14', 
         'lazyArray_15', 
         'qwOpen_16', 
         'qwOpen_17', 
         'qwOpen_18', 
         'qwClose_19', 
         'optLazyItems_20', 
         'optLazyItems_21', 
         'lazyItems_22', 
         'lazyItems_23', 
         'lazyItem_24', 
         'legacyArray_25', 
         'optItems_26', 
         'optItems_27', 
         'items_28', 
         'items_29', 
         'item_30', 
         'item_31', 
         'rawStr_32', 
         'rawStr_33', 
         'section_34', 
         'sectionNames_35', 
         'sectionNames_36', 
         'sectionNames_37', 
         'sectionName_38', 
         'sectionNameSequence_39', 
         'sectionNameSequence_40', 
         'rule_41', 
         'rule_42', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'lexerRule_45', 
         'lexerRhss_46', 
         'lexerRhss_47', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'lexerRhs_52', 
         'lexerRhs_53', 
         'lexerElements_54', 
         'lexerElements_55', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'lexerElement_58', 
         'lexerElement_59', 
         'lexerAtom_60', 
         'lexerAtom_61', 
         'lexerAtom_62', 
         'lexerAtom_63', 
         'lexerAtom_64', 
         'lexerAtom_65', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'ebnfSuffix_70', 
         'ebnfSuffix_71', 
         'ebnfSuffix_72', 
         'parserRule_73', 
         'parserRuleType_74', 
         'parserRuleType_75', 
         'parserRhss_76', 
         'parserRhss_77', 
         'parserRhs_78', 
         'parserRhs_79', 
         'parserElements_80', 
         'parserElements_81', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'parserElement_84', 
         'parserElement_85', 
         'parserAtom_86', 
         'parserAtom_87', 
         'parserAtom_88', 
         'id_89', 
         'id_90', 
         'id_91', );
  $self;
}

#line 283 "Parser.eyp"


require 'Parse/Easy/Parse/Lexer.pl';
__PACKAGE__->lexer(\&__LEXER);
__PACKAGE__->error(\&__EXPECT);

=for None

=cut


#line 1814 Parser.pm



1;
