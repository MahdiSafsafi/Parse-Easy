#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/CharacterSet.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::CharacterSet;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::IntervalSet);
use Parse::Easy::IntervalSet;

sub codePointToString {
	my ($codepoint) = @_;
	local $_ = chr $codepoint;
	if ( $_ eq ' ' ) {
		return sprintf "'%s'", $_ ;
	}
	elsif (/\p{XPosixPrint}/) {
		return sprintf "'%s'", $_ ;
	}
	else {
		return sprintf "'\\u%04x'", $codepoint ;
	}	
}

sub new {
	my ($class) = shift;
	my $self = $class->SUPER::new(@_);
}

sub toString {
	my ($self) = @_;	
	my @sets   = $self->sets();
	my @data   = ();
	foreach my $set (@sets) {
		my $min = $set->min();
		my $max = $set->max();
		my $data =
		  $min == $max
		  ? sprintf "%s", codePointToString($min) 
		  : sprintf "%s .. %s", codePointToString($min), codePointToString($max);

		push @data, $data;
	}
	sprintf "[%s]", join ', ', @data ;
}
1;
