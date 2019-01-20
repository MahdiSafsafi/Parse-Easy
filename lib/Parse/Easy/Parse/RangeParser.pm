#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parse/RangeParser.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parse::RangeParser;
use strict;
use warnings;
use Parse::Easy::Parse::RangeLexer;
our @ISA = qw(Parse::Easy::Parse::RecursiveDescentParser);
use Parse::Easy::Parse::RecursiveDescentParser;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Wildcard;

sub new {
	my ( $class, $lexer ) = @_;
	my $self = $class->SUPER::new($lexer);
	$self;
}

sub atom {
	my ($self) = @_;

	# atom : '(' expression ')'
	#      | '[' range      ']'
	#      | CODEPOINTS
	#      ;

	my $lexer = $self->{lexer};
	my $token = $lexer->peek();
	if ( $token->{type} eq 'LPAREN' ) {
		$lexer->advance();
		my $expression = $self->expression();
		$lexer->skip( ['RPAREN'] );
		return $expression;
	}
	elsif ( $token->{type} eq 'LBRACK' ) {
		$lexer->advance();
		my $expression = $self->range();
		$lexer->skip( ['RBRACK'] );
		return $expression;
	}
	elsif ( $token->{type} eq 'CODEPOINTS' ) {
		$lexer->advance();
		return $token->{value};
	}
	else {
		$lexer->expect( ['CODEPOINTS'], $token->{type}, $token->{type} );
	}
}

sub unaryExpression {
	my ($self) = @_;

	# unaryExpression : NOT atom
	#                 | atom
	#                 ;

	my $lexer      = $self->{lexer};
	my $negate     = $lexer->match( ['BANG'] );
	my $expression = $self->atom();
	if ($negate) {
		my $wildcard = Parse::Easy::Wildcard::wildcard();
		$wildcard->D($expression);
		return $wildcard;
	}
	$expression;
}

sub addSubExpression {
	my ($self) = @_;

	# addSubExpression : addSubExpression (ADD|SUB) unaryExpression
	#                  | unaryExpression
	#                  ;

	my $lexer      = $self->{lexer};
	my $expression = $self->unaryExpression();
	while ( $lexer->match( [ 'PLUS', 'MINUS' ] ) ) {
		my $minus = $lexer->matched() eq 'MINUS';
		my $right = $self->unaryExpression();
		if ($minus) {
			$expression->D($right);
		}
		else {
			$expression->U($right);
		}
	}
	$expression;
}

sub andExpression {
	my ($self) = @_;

	# andExpression : andExpression AND addSubExpression
	#               | addSubExpression
	#               ;

	my $lexer      = $self->{lexer};
	my $expression = $self->addSubExpression();
	while ( $lexer->match( ['AND'] ) ) {
		my $right = $self->addSubExpression();
		$expression->I($right);
	}
	$expression;
}

sub orExpression {
	my ($self) = @_;

	# orExpression : orExpression (OR|XOR) andExpression
	#              | andExpression
	#              ;

	my $lexer      = $self->{lexer};
	my $expression = $self->andExpression();
	while ( $lexer->match( [ 'BAR', 'CIRCUMFLEX' ] ) ) {
		my $or    = $lexer->matched() eq 'BAR';
		my $right = $self->andExpression();
		if ($or) {
			$expression->U($right);
		}
		else {
			$expression->X($right);
		}
	}
	$expression;
}

sub expression {
	my ($self) = @_;

	# expression : orExpression ;
	$self->orExpression();
}

sub element {
	my ($self) = @_;

	# element : CODEPOINTS
	#         | CODEPOINT
	#         ;
	my %accept = map { $_ => 1 } qw/AND BAR BANG PLUS MINUS CIRCUMFLEX LPAREN RPAREN/;
	my $set    = undef;
	my $lexer  = $self->{lexer};
	my $from   = $lexer->peek();
	if ( $from->{type} eq 'CODEPOINT' ) {
		$lexer->advance();
		my $minus = $lexer->peek();
		if ( $minus->{type} eq 'MINUS' ) {
			$lexer->advance();
			my $to = $lexer->peek();
			if ( $to->{type} eq 'CODEPOINT' ) {
				$lexer->advance();
				$set = Set::IntSpan->new("$from->{value}-$to->{value}");
			}
			else {
				$set = Set::IntSpan->new();
				$set->U( $from->{value} );
				$set->U( $minus->{value} );
			}
		}
		else {
			$set = Set::IntSpan->new( $from->{value} );
		}
	}
	elsif ( $from->{type} eq 'CODEPOINTS' ) {
		$lexer->advance();
		return $from->{value};
	}
	elsif ( exists $accept{ $from->{type} } ) {
		$lexer->advance();
		$set = Set::IntSpan->new( $from->{value} );
	}
	else {
		$lexer->expect( [ 'CHAR', 'CODEPOINTS' ], $from->{type}, $from->{type} );
	}
	$set;
}

sub elements {
	my ($self) = @_;

	# elements : elements element
	#          | element
	#          ;
	my $lexer = $self->{lexer};
	my $set   = Set::IntSpan->new();
	while (1) {
		my $token = $lexer->peek();
		$token->{type} eq 'RBRACK' || $token->{type} eq 'EOF' and last;
		my $element = $self->element();
		$set->U($element);
	}
	$set;
}

sub unary {
	my ($self) = @_;
	my $token  = $self->{lexer}->peek();
	my $negate = 0;
	$token->{type} eq 'CIRCUMFLEX' && $self->{lexer}->advance() && ++$negate;
	my $result = $self->elements();
	if ($negate) {
		my $wildcard = Parse::Easy::Wildcard::wildcard();
		$wildcard->D($result);
		return $wildcard;
	}
	$result;
}

sub range {
	my ($self)     = @_;
	my $lexer      = $self->{lexer};
	my $expression = $self->unary();
}

sub extendedExpression {
	my ($self)     = @_;
	my $lexer      = $self->{lexer};
	my $expression = undef;
	if ( $lexer->match( ['EXTENDED'] ) ) {
		$expression = $self->expression();
	}
	else {
		$expression = $self->range();
	}
	$expression;
}

sub parse {
	my ($self) = @_;
	my $lexer = $self->{lexer};
	$lexer->advance();
	$lexer->skip( ['LBRACK'] );
	my $expression = $self->extendedExpression();
	my $rbrack     = $lexer->peek();
	$rbrack->{type} eq 'RBRACK' or $lexer->expect( ['RBRACK'] );
	$self->{set} = $expression;
}
1;
