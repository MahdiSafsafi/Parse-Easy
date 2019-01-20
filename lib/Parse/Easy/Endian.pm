#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Endian.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Endian;
use strict;
use warnings;
use Carp;
use base 'Exporter';

our @EXPORT = qw(LITTLEENDIAN BIGENDIAN BE LE unpackInteger);

use constant LITTLEENDIAN => 0;
use constant BIGENDIAN    => 1;
use constant BE           => BIGENDIAN;
use constant LE           => LITTLEENDIAN;

my %sz2p = ( 1 => 'C', 2 => 'S', 4 => 'L', 8 => 'Q' );

sub unpackInteger {
	my ( $value, $size, $signed, $endian ) = @_;
	my $pattern = $sz2p{$size};
	$signed and $pattern = lc $pattern;
	$endian && $size != 1 and $pattern .= '>';
	$value // croak;
	unpack "C*", pack $pattern, $value;
}

1;
