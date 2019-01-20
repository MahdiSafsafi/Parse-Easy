#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Compiler/Utils.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Compiler::Utils;
use strict;
use warnings;
no warnings "portable";
use base 'Exporter';
use feature qw(say);
our @EXPORT = qw(sizeOfInteger);

sub sizeOfInteger {
	my ( $value, $signed ) = @_;
	if ( !$signed ) {
		( $value & 0xff ) == $value       and return 8;
		( $value & 0xffff ) == $value     and return 16;
		( $value & 0xffffffff ) == $value and return 32;
		return 64;
	}
	else {
		$value >= -127        && $value <= 127        and return 8;
		$value >= -32768      && $value <= 32767      and return 16;
		$value >= -2147483648 && $value <= 2147483647 and return 32;
		return 64;
	}
}

1;
