#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Epsilon.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Epsilon;
use strict;
use warnings;
use Data::Dump qw(pp);
use feature qw(say);
use Parse::Easy::Term;
our @ISA = qw(Parse::Easy::Term);
use Carp;
