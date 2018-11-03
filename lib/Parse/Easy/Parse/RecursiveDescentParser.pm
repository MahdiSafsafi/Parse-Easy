#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parse/RecursiveDescentParser.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parse::RecursiveDescentParser;
use strict;
use warnings;

sub new {
	my ( $class, $lexer ) = @_;
	my $self = { lexer => $lexer, };
	bless $self, $class;
	$self;
}
sub lexer { $_[0]->{lexer} };
sub parse { ... }
sub error{
	my($self,$msg)=@_;
	die $msg;
}
1;

