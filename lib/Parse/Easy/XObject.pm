#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/XObject.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::XObject;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Token;
our @ISA = qw(Parse::Easy::Token);
use Scalar::Util qw(refaddr);

sub new {
	my ( $class, $ref ) = @_;
	my $self = $class->SUPER::new();
	$self->{xobject} = $ref;
	$self;
}

sub same {
	my ( $self, $that ) = @_;
	defined $that || return 0;
	$self == $that
	  || $self->type() eq $that->type() && $self->{xobject} == $that->{xobject};
}

sub xobject {
	my ( $self, $value ) = @_;
	$self->{xobject} = $value // $self->{xobject};
}

sub clone {
	my ($self) = @_;
	Parse::Easy::XObject->new( $self->{xobject} );
}

sub toString {
	my ($self) = @_;
	refaddr( $self->{xobject} );
}
1;
