#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Literal.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Literal;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Token);
use Parse::Easy::Token;
use Parse::Easy::CharacterSet;

sub new {
	my ( $class, $bytes ) = @_;
	my $self = $class->SUPER::new();
	$self->{sets} = $bytes;
	$self;
}

sub toCharSets {
	my ($self) = @_;
	my @sets = ();
	foreach my $set ( @{ $self->{sets} } ) {
		push @sets, Parse::Easy::CharacterSet->new($set);
	}
	wantarray ? @sets : \@sets;
}

1;