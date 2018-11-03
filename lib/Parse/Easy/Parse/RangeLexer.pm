#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parse/RangeLexer.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parse::RangeLexer;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Parse::RecursiveDescentLexer);
use Parse::Easy::Parse::RecursiveDescentLexer;
use Unicode::UCD qw(prop_invlist);
use Set::IntSpan;
use Parse::Easy::Wildcard;

sub invertedListToSet {
	my ($ref) = @_;
	my $set = Set::IntSpan->new();
	for ( my $i = 0 ; $i < @$ref ; $i += 2 ) {
		my $from = $ref->[$i];
		my $to =
		  ( $i + 1 ) < @$ref
		  ? $ref->[ $i + 1 ] - 1
		  : $Unicode::UCD::MAX_CP;
		$from == 0x110000 and last;
		$set->U("$from-$to");
	}
	$set;
}

sub new {
	my ( $class, $parent ) = @_;
	my $self = $class->SUPER::new( $parent->YYInput() );
	$self->{EXTENDED} = 0;
	$self->{parent}   = $parent;
	$self;
}

sub error {
	my ( $self, $msg ) = @_;
	$self->{ERROR}->( $self->{parent}, $msg );
}

sub expect {
	my ( $self, $expected, $curtok, $curval ) = @_;
	$self->{EXPECT}->( $self->{parent}, $expected, $curtok, $curval );
}

sub next {
	my ($self) = @_;
	my %escape = (
		'n'  => ord "\n",
		't'  => ord "\t",
		'r'  => ord "\r",
		'.'  => ord ".",
		'\'' => ord '\'',
		'\\' => ord '\\',
	);
	for ( ${ $self->{input} } ) {
		$self->{EXTENDED} && /\G(\s+)/gc;

		/\G(\[)/gc and return ( 'LBRACK', ord $1 );
		/\G(\])/gc and return ( 'RBRACK', ord $1 );
		/\G(\()/gc and return ( 'LPAREN', ord $1 );
		/\G(\))/gc and return ( 'RPAREN', ord $1 );

		/\G(\^)/gc and return ( 'CIRCUMFLEX', ord $1 );
		/\G(\!)/gc and return ( 'BANG',       ord $1 );

		/\G(-)/gc  and return ( 'MINUS',      ord $1 );
		/\G(\+)/gc and return ( 'PLUS',       ord $1 );
		/\G(\|)/gc and return ( 'BAR',        ord $1 );
		/\G(&)/gc  and return ( 'AND',        ord $1 );
		/\G(\.)/gc and return ( 'CODEPOINTS', Set::IntSpan->new( sprintf "%s-%s", 0, oct "0xffff" ) );

		if (/\G(\\)/gc) {
			/\G(.)/gc or $self->error('unexpected end of file');
			my $next = $1;
			exists $escape{$next} && return ( 'CODEPOINT', $escape{$next} );
			if ( $next eq 'X' ) {
				$self->{EXTENDED} = 1;
				return ( 'EXTENDED', 0 );
			}
			if ( $next eq 'p' || ( $next eq 'P' and my $negate = 1 ) ) {
				my $propname = '';
				if (/\G([a-zA-Z][a-z_A-Z0-9]*)/gc) {
					$propname = $1;
				}
				else {
					/\G(.)/gc && $1 eq '{' or $self->expect( ['LBRACE'], $1, $1 );
					/\G([^}\]\n]+)/gc and $propname = $1;
					/\G(.)/gc && $1 eq '}' or $self->expect( ['RBRACE'], $1, $1 );
				}
				$propname or $self->error('empty property found.');
				my @invlist = prop_invlist($propname);
				my $set     = invertedListToSet( \@invlist );
				$set->empty() and $self->error( sprintf "unable to find property '%s'", $propname );
				if ($negate) {
					my $wildcard = Parse::Easy::Wildcard::wildcard();
					$wildcard->D($set);
					$set = $wildcard;
				}
				return ( 'CODEPOINTS', $set );
			}
			if ( $next eq 'u' ) {
				/\G([a-fA-F0-9]{4})/gc || /\G({[a-fA-F0-9]{1,4}})/gc or $self->error("invalid escape \\u format.");
				return ( 'CODEPOINT', oct "0x$1" );
			}
			return ( 'CODEPOINT', ord $next );
		}

		/\G(.)/gc and return ( 'CODEPOINT', ord $1 );
		return ( 'EOF', '' );
	}
}



1;
