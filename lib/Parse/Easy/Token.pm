#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Token.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Token;
use strict;
use warnings;
use Data::Dump qw(pp);
use feature qw(say);
use Carp;

sub new {
	my ($class) = @_;
	my $self = { type => undef, };
	bless $self, $class;
	ref($self) =~ /(\w+)$/ and $self->{type} = lc $1;
	$self;
}

sub clone    { ... }
sub same     { ... }
sub toString { ... }

sub findIn {
	my ( $self, $array ) = @_;
	my $i = $self->indexIn($array);
	return $i >= 0 ? $array->[$i] : undef;
}

sub indexIn {
	my ( $self, $array ) = @_;
	$self->same( $array->[$_] ) and return $_ for ( 0 .. $#$array );
	-1;
}

sub existsIn {
	my ( $self, $array ) = @_;
	$self->indexIn($array) >= 0;
}

sub addUniqueTo {
	my ( $self, $array ) = @_;
	$self->existsIn($array) and return 0;
	push @$array, $self;
}

sub type {
	my ($self) = @_;
	$self->{type};
}
1;
