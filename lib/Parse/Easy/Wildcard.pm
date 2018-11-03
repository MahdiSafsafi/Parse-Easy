#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Wildcard.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Wildcard;
use strict;
use warnings;
use Set::IntSpan;

$Parse::Easy::Wildcard::MIN = 0x0000;
$Parse::Easy::Wildcard::MAX = 0xffff;

sub wildcard {
	Set::IntSpan->new( sprintf "%s-%s", $Parse::Easy::Wildcard::MIN, $Parse::Easy::Wildcard::MAX )
}
1;
