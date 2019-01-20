#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Target/Pascal/Header.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Target::Pascal::Header;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw/get_header/;
use Parse::Easy::Version;

my $Major = $Parse::Easy::Version::Major;
my $Minor = $Parse::Easy::Version::Minor;

my $header=<<EOH;

// -------------------------------------------------------
//
// This file was generated using Parse::Easy v$Major.$Minor alpha.
//
// https://github.com/MahdiSafsafi/Parse-Easy
//
// DO NOT EDIT !!! ANY CHANGE MADE HERE WILL BE LOST !!!
//
// -------------------------------------------------------

EOH

sub get_header{$header}
1;