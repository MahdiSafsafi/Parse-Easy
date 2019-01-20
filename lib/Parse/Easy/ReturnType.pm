#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/ReturnType.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::ReturnType;
use strict;
use warnings;
use Data::Dump qw(pp);
use feature qw(say);
use Parse::Easy::Term;
our @ISA = qw(Parse::Easy::Token);
use Carp;

sub new {
	my ( $class, $type ) = @_;
	my $self = $class->SUPER::new();
	$self->{value} = $type;
	$type=~s/^T//;
	$self->{name} = sprintf "FReturnValueAs%s",$type;
	
	$self;
}

sub value {
	my ($self) = @_;
	$self->{value};
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
	Parse::Easy::ReturnType->new( $self->{name} );
}

sub toString {
	my ($self) = @_;
	$self->{name};
}

1;
