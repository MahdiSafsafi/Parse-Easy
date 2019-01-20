#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parse/Lexer.pl Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

use strict;
use warnings;
use Data::Dump qw/pp/;
use feature qw/say/;
use Carp;
use Readonly;
use Parse::Easy::Parse::RangeLexer;
use Parse::Easy::Parse::RangeParser;
use Parse::Easy::Literal;
use Parse::Easy::Code;
use Parse::Easy::Wildcard;
use Unicode::UCD qw/casefold charinfo casespec/;
use Set::IntSpan;

Readonly my $SECTION_DEFAULT => 0;
Readonly my $SECTION_USE     => 1;

Readonly my $ERROR_LITERAL_EXPLICIT_NEWLINE  => "literal can't have explicit newline.";
Readonly my $ERROR_LITERAL_EMPTY             => "literal can't be empty.";
Readonly my $ERROR_INVALID_UNICODE_CODEPOINT => "invalid unicode codepoint.";
Readonly my $FERROR_CHAR_SURPRISE            => "char '%s' came to me as a complete surprise.";

# ----------------------- helper for parser -----------------------
sub curpos {

	# return current pos of input.
	pos( ${ $_[0]->YYInput } );
}

sub skipLine {

	# skip line and remember cursor position
	# this position can be used later to determine column.
	my ($parser) = @_;
	$parser->line( $parser->line + 1 );
	$parser->YYData->{linepos} = curpos($parser);
}

sub column {

	# return column position based on linepos.
	# column is relative to linepos.
	curpos( $_[0] ) - $_[0]->YYData->{linepos};
}

# ---------------------------------------------------------------------

sub DQLITERAL {

	# single quoted literal.
	my ($parser)   = @_;
	my @codepoints = ();
	my $flags      = 0;
	use constant F_CASE_INSENSITIVE => 1;
	my @stack = ();
	my $addcp = sub {
		my ($codepoint) = @_;
		my $set = Set::IntSpan->new($codepoint);
		if ( $flags & F_CASE_INSENSITIVE ) {
			my $casefold = casefold($codepoint);
			$casefold or die $codepoint;
			$set->U( $casefold->{simple} );
		}
		push @codepoints, $set;
	};

	my $valid    = 0;
	my $lastChar = '';
	my %escape   = (
		'n'  => ord "\n",
		't'  => ord "\t",
		'r'  => ord "\r",
		'"'  => ord '"',
		'\\' => ord '\\',
	);
	for ( ${ $parser->YYInput } ) {
		while (/\G(.)/gc) {
			my $char = $lastChar = $1;
			$char eq '"' && ++$valid and last;
			if ( $char eq '\\' ) {
				/\G(.)/gc or last;
				my $next = $lastChar = $1;
				$next eq 'u' && ( /\G([a-fA-F0-9]{4})/gc || /\G({[a-fA-F0-9]{1,4}})/gc or __ERROR( $parser, $ERROR_INVALID_UNICODE_CODEPOINT ) )
				  and $addcp->( oct "0x$1" )
				  and next;
				exists $escape{$next} and $addcp->( $escape{$next} ) and next;
				uselessEscape( $parser, $next );
				$addcp->( ord $next );
				next;
			}
			$addcp->( ord $char );
		}
	}
	$valid or __EXPECT( $parser, ['"'], $lastChar, $lastChar );
	@codepoints or __ERROR( $parser, $ERROR_LITERAL_EMPTY );
	my $literal = Parse::Easy::Literal->new( \@codepoints );
	return ( 'DQ_LITERAL', $literal );
}

sub SQLITERAL {

	# single quoted literal.
	my ($parser)   = @_;
	my $valid      = 0;
	my $lastChar   = '';
	my @codepoints = ();

	my $addcp = sub {
		my ($codepoint) = @_;
		my $set = Set::IntSpan->new($codepoint);
		push @codepoints, $set;
	};

	for ( ${ $parser->YYInput } ) {
		while (/\G(.)/gc) {
			my $char = $lastChar = $1;
			$char eq "'" and ++$valid and last;
			if ( $char eq '\\' && /\G(')/gc ) {
				$addcp->( ord $1 );
				next;
			}
			$addcp->( ord $char );
		}
	}
	$valid or __EXPECT( $parser, ['\''], $lastChar, $lastChar );
	@codepoints or __ERROR( $parser, $ERROR_LITERAL_EMPTY );
	my $literal = Parse::Easy::Literal->new( \@codepoints );
	return ( 'SQ_LITERAL', $literal );
}

sub ACTION {
	my ($parser) = @_;
	return PascalCode($parser);
}

sub PascalCode {
	my ($parser) = @_;
	${ $parser->YYInput } =~ m<
\G(
  \{
     (
       (
         # skip comments (* *):
         \(\* ( [^\*]* | \* [^\)\*]* )* \*\)
         # skip comments {}:
        | \{ [^\}]* \}
        # skip comments // :
        | \/\/ [^\n]*
        # skip literal:
        | \' ( [^\n\'] | \'\' )* \'
        # skip any char that is not in ['{', '/', '(', "'"]:
        | [^\{\'\/\(]*
        # char is either '(' or '/': 
        | ( 
             # skip it if it's not a comment opening '(*' or '(}'
              \( [^\*\}]? 
             # skip it if it's not '//' or '/}'
             | \/ [^\/\}]? 
          )  
       )*
     )
  \}
)
>xsgc or __ERROR( $parser, 'Unable to read action' );
	return ( 'ACTION', Parse::Easy::Code->new($2) );
}

sub RANGE {
	my ($parser) = @_;
	my $lexer = Parse::Easy::Parse::RangeLexer->new($parser);
	$lexer->{ERROR}  = \&__ERROR;
	$lexer->{EXPECT} = \&__EXPECT;
	my $rangeParser = Parse::Easy::Parse::RangeParser->new($lexer);
	my $ast         = $rangeParser->parse();
	( 'RANGE', $ast );
}

sub __PARSE {
	my ($parser) = @_;
	unless ( $parser->YYData->{init}++ ) {
		$parser->YYData->{linepos}++;
		$parser->YYData->{lastToken} = '';
		$parser->YYData->{qwclose}   = '';
		pushSection( $parser, $SECTION_DEFAULT );
	}
	my $lastToken = $parser->YYData->{lastToken};
	my $section   = section($parser);
	for ( ${ $parser->YYInput } ) {
		my $n = 0;
		m{
		   \G(
		       (
                   \h           # any white space.
                 | \/\/(.*)     # comments.
                 | \n (?{$n++}) # newline.
               )+
             )
		 }xgc;
		skipLine($parser) while ( $n-- );

		/\G(\()/gc and return ( 'LPAREN', $1 );
		/\G(\))/gc and return ( 'RPAREN', $1 );

		/\G(\.)/gc  and return ( 'DOT',        $1 );
		/\G(\|)/gc  and return ( 'BAR',        $1 );
		/\G(\::)/gc and return ( 'COLONCOLON', $1 );
		/\G(\:)/gc  and return ( 'COLON',      $1 );
		/\G(\,)/gc  and return ( 'COMMA',      $1 );
		/\G(\;)/gc  and return ( 'SEMICOLON',  $1 );
		/\G(\-)/gc  and return ( 'MINUS',      $1 );
		/\G(\+)/gc  and return ( 'PLUS',       $1 );
		/\G(\*)/gc  and return ( 'STAR',       $1 );
		/\G(\?)/gc  and return ( 'QUESTION',   $1 );
		/\G(\^)/gc  and return ( 'CIRCUMFLEX', $1 );
		/\G(\$)/gc  and return ( 'DOLLAR',     $1 );
		/\G(\<)/gc  and return ( 'LT',         $1 );
		/\G(\>)/gc  and return ( 'GT',         $1 );
		/\G(\/)/gc  and return ( 'SLASH',      $1 );

		# Literal:
		if ( $section == $SECTION_USE ) {
			/\G('(.*?)')/gc and return ( 'SQRAWSTR', $2 );
			/\G("(.*?)")/gc and return ( 'DQRAWSTR', $2 );
		}
		m/\G(')/gc and return SQLITERAL($parser);
		/\G(")/gc  and return DQLITERAL($parser);

		#
		/\G(\{)/ and return ACTION($parser);
		/\G(\[)/ and return RANGE($parser);

		# reserved keywords:
		/\G(grammar)\b/gc  and return ( 'GRAMMAR',  $1 );
		/\G(fragment)\b/gc and return ( 'FRAGMENT', $1 );
		/\G(section)\b/gc  and return ( 'SECTION',  $1 );
		/\G(use)\b/gc      and return ( 'USE',      $1 );
		/\G(qw)\b/gc       and return ( 'QW',       $1 );
		/\G(as)\b/gc       and return ( 'AS',       $1 );

		if ( $lastToken eq 'USE' ) {
			/\G([a-z_A-Z0-9:]+)/gc;
			return ( 'PACKAGE_NAME', $1 );
		}
		m/\G([a-z][a-z_A-Z0-9]*)/gc and return ( 'NOTERM',     $1 );
		/\G([A-Z][a-z_A-Z0-9]*)/gc  and return ( 'TERM',       $1 );
		/\G(_+[a-zA-Z0-9]+)/gc      and return ( 'UNDERSCORE', $1 );
		/\G(.)/gc                   and return ( $1,           $1 );
		return ( '', undef );
	}
}

sub section     { $_[0]->YYData->{sections}->[-1] }
sub pushSection { push @{ $_[0]->YYData->{sections} }, $_[1] }
sub popSection  { pop @{ $_[0]->YYData->{sections} } }

sub __LEXER {
	my ($parser) = @_;
	my @result   = __PARSE($parser);
	my $token    = $result[0];
	my %qwpair   = (
		LPAREN => 'RPAREN',
		SLASH  => 'SLASH',
		LT     => 'GT',
	);
	if ( $token eq 'USE' ) {
		pushSection( $parser, $SECTION_USE );
	}
	elsif ( $token eq 'SEMICOLON' ) {
		my $section = section($parser);
		$section == $SECTION_USE and popSection($parser);
	}
	if ( $token ne '' && $parser->YYData->{qwclose} eq $token ) {
		$result[0] = 'QWCLOSE';
		$parser->YYData->{qwclose} = '';
	}
	if ( $parser->YYData->{lastToken} eq 'QW' && exists $qwpair{$token} ) {
		$parser->YYData->{qwclose} = $qwpair{$token};
	}
	$parser->YYData->{lastToken} = $token;
	@result;
}

sub __ERROR {
	my ( $self, $msg ) = @_;
	my ( $line, $column ) = ( $self->line, column($self) );
	die sprintf "error in file '%s' line %d column %d: %s",    #filename.line.column:msg
	  $self->YYFilename(), $line, $column, $msg;
}

sub uselessEscape {
	my ( $self, $char ) = @_;
	my ( $line, $column ) = ( $self->line, column($self) );
	warn sprintf <<'EOW'
warn in file '%s' line %d column %d:
useless escape character '\%s'. I will assume that you mean character '%s'.
  note that using unrecognized escaped character may break your parser for future releases.
EOW
	  , $self->YYFilename(), $line, $column, $char, $char;
}

sub __EXPECT {
	my ($self) = shift;
	my @expect = ();
	my ( $expect, $curtok, $curval ) = @_;
	@expect = $expect ? @$expect : $self->YYExpect();
	$curtok = $curtok // $self->YYCurtok() // 'EOF';
	$curval = $curval // $self->YYCurval() // 'EOF';
	$expect = join( ', ', @expect );
	my ( $line, $column ) = ( $self->line, column($self) );

	die sprintf <<'EOE'
error in file '%s' line %d column %d:	
  near terminal %s '%s'.
  expecting one of the following terminal [%s].
EOE
	  , $self->YYFilename(), $line, $column,    # filename.line.column
	  $curtok, $curval, $expect;
}

1;
