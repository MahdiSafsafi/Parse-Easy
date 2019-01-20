#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parser/Action.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parser::Action;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Token;
use Parse::Easy::Utils qw(sameItems);
our @ISA = qw(Parse::Easy::Token);

sub new {
	my ( $class, $action, $value ) = @_;
	my $self = $class->SUPER::new();
	$self->{type} = $action;
	$self->{value}  = $value;
	$self;
}
1;
