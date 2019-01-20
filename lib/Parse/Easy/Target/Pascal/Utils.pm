#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Target/Pascal/Utils.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Target::Pascal::Utils;
use strict;
use warnings;
use autodie;
use Exporter qw(import);
use Parse::Easy::Target::Pascal::Config qw/get_config/;
our @EXPORT_OK = qw/generateRes/;

my $config = get_config();

sub generateRes {
	my ( $name, $rc, $res, $binary ) = @_;
	my $rcc = sprintf '"%s"', $config->{rcc};
	open my $fh, '>', $rc;
	printf $fh "%s RCDATA %s\n", $name, $binary;
	close $fh;
	qx<$rcc $rc>;
}
1;
