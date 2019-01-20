#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parse/RecursiveDescentLexer.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parse::RecursiveDescentLexer;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);

sub new {
	my ( $class, $input ) = @_;
	my $self = {
		input   => ref($input) ? $input : \$input,
		current => undef,
		matched => undef,
	};
	bless $self, $class;
	$self;
}

sub next     { ... }
sub error    { ... }
sub expect   { ... }
sub matched { $_[0]->{matched} }

sub fetch {
	my $self = shift;
	my ( $type, $value ) = $self->next();
	return {
		type  => $type,
		value => $value,
	};
}

sub check {
	my ( $self, $type ) = @_;
	$self->EOF() and return 0;
	$self->peek()->{type} eq $type;
}

sub match {
	my ( $self, $symbols, $raise ) = @_;

	for my $i ( 0 .. @$symbols - 1 ) {
		my $symbol = $symbols->[$i];
		if ( $self->check($symbol) ) {
			$self->{matched} = $symbol;
			$self->advance();
			return 1;
		}
	}
	if ($raise) {
		$self->expect(  $symbols );
	}
	0;
}

sub skip {
	my ( $self, $symbols ) = @_;
	$self->match( $symbols, 1 );
}

sub EOF {
	my ($self) = @_;
	$self->peek()->{type} eq '';
}

sub advance {
	my ($self) = @_;
	my $current = $self->{current};
	$self->{current} = $self->fetch();
	$current;
}

sub peek {
	my ($self) = @_;
	$self->{current};
}

1;
