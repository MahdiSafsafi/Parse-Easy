#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Utils.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Utils;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Exporter qw(import);
our @EXPORT_OK = qw(elapsed sameItems normalizeRanges);
use Unicode::UCD;
use Carp;
use Time::HiRes;

sub elapsed {
	my ( $name, $code ) = @_;
	my $start = [Time::HiRes::gettimeofday];
	$code->();
	my $end = [Time::HiRes::gettimeofday];
	my $elapsed = Time::HiRes::tv_interval( $start, $end );
	printf "function %s executed in %s.\n", $name, $elapsed;
}

sub normalizeRanges {
	my ($ref)  = @_;
	my @ranges = ();
	my $i      = 0;
	my $set    = Parse::Easy::CharacterSet->new();
	while (1) {
		my $current = $ref->[ $i++ ] // last;
		my $next = $ref->[ $i++ ] // push( @ranges, { from => $current, to => $Unicode::UCD::MAX_CP } ) && last;
		push @ranges, { from => $current, to => --$next };
	}
	foreach my $range (@ranges) {
		my $pattern = sprintf "%d-%d", $range->{from}, $range->{to};
		my $interval = Parse::Easy::CharacterSet->new($pattern);
		$set->U($interval);
	}
	$set;
}

sub sameItems {
	my ( $array1, $array2, $byReference ) = @_;
	my $count = scalar @$array1;
	$count != scalar @$array2 and return 0;
	for my $i ( 0 .. $count - 1 ) {
		my $a   = $array1->[$i];
		my $b   = $array2->[$i];
		my $ref = ref($a);
		$ref ne ref($b) and return 0;
		$ref && $a == $b and next;

		if ($byReference) {
			!$ref and croak( sprintf("sameItems expecting reference item.") );
			$a == $b or return 0;
		}
		else {
			if ($ref) {
				$a->same($b) or return 0;
			}
			else {
				$a eq $b or return 0;
			}
		}
	}
	1;
}

1;
