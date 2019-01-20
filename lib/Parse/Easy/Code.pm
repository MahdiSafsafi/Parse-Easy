#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Code.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Code;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Token);
use Parse::Easy::Token;
use Digest::MD5 qw(md5 md5_hex);

sub new {
	my ( $class, $code ) = @_;
	my $self = $class->SUPER::new();
	$self->{code}     = $code;
	$self->{index}    = undef;
	$self->{hashcode} = md5_hex($code);
	$self;
}

sub index {
	my ( $self, $value ) = @_;
	$self->{index} = $value // $self->{index};
}

sub code {
	my ( $self, $value ) = @_;
	$self->{code} = $value // $self->{code};
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->type() eq $that->type() && $self->{hashcode} eq $that->{hashcode};
}

sub clone {
	my ($self) = @_;
	bless {
		code     => $self->{code},
		hashcode => $self->{hashcode},
	  },
	  __PACKAGE__;
}

sub toString {
	my ($self) = @_;
	'{' . $self->{code} . '}';
}
1;
