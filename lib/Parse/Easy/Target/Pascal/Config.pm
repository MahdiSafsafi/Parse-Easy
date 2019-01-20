#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Target/Pascal/Config.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Target::Pascal::Config;
use strict;
use warnings;
use Storable qw/dclone/;
use Exporter qw(import);
our @EXPORT_OK = qw/get_config/;

my %config = ( rcc => 'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\BRCC32.EXE', );

sub get_config { dclone \%config }
1;
