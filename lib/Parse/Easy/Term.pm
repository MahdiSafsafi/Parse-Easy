#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Term.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Term;
use strict;
use warnings;
use Data::Dump qw(pp);
use feature qw(say);
use Parse::Easy::Token;
our @ISA = qw(Parse::Easy::Token);
use Carp;

sub new {
	my ( $class, $name ) = @_;
	my $self = $class->SUPER::new();
	$self->{name} = $name;
	$self;
}

sub name {
	my ($self) = @_;
	$self->{name};
}

sub same {
	my ( $self, $that ) = @_;
	defined $that or return 0;
	$self == $that
	  || $self->type() eq $that->type() 
	  && $self->{name} eq $that->{name};
}

sub clone {
	my ($self) = @_;
	Parse::Easy::Token->new( $self->{name} );
}

sub toString {
	my ($self) = @_;
	$self->{name};
}
1;
