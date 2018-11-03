#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/opcodes.pl Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);

my @instructions = ();
my $file         = 'opcodes.txt';
open my $fh, '<', $file or die $!;

my %char2size = (
	b => 8,
	w => 16,
	d => 32,
);

sub maxSize {
	my ($patterns) = @_;
	my $result = 0;
	for my $i ( 0 .. @$patterns - 1 ) {
		local $_ = $patterns->[$i];
		if (/^0x[a-f0-9]{2}$/) {
			$result += 8;
		}
		elsif (/^o([bwd])$/) {
			$result += $char2size{$1};
		}
		elsif (/^[iu](\d+)$/) {
			$result += $1;
		}
		elsif (/^mr$/) {
			$result += 8;
		}
		elsif (/^mf$/) {
			$result += 8;
			$result += 32;
		}
		else {
			die "unable to handle '$_' in patterns.";
		}
	}
	$result % 8 and die "invalid instruction size.";

	$result / 8;
}

sub processInsn {
	my ( $syntax, $opcodes, $metadata ) = @_;
	local $_ = $syntax;
	s/^(\w+)\s*//;
	my $mnem = $1;
	my @args = split /\s*,\s*/;
	$_ = $opcodes;
	s/^\s+|\s+$//g;
	my @patterns = ();
	@patterns = split /\s+/ unless (/^\s*$/);
	my ( $immediate, $relative ) = ( 0, 0 );

	foreach (@args) {
		/^[iu]mm\d+$/ and $immediate++;
		/^rel\d+$/    and $relative++;
	}
	my $maxsize = maxSize( \@patterns );
	$metadata = $metadata // '';
	my @flags = $metadata =~ /(\w+)/g;
	my $insn  = {
		mnem      => $mnem,
		args      => \@args,
		patterns  => \@patterns,
		relative  => $relative,
		immediate => $immediate,
		maxsize   => $maxsize,
	};
	$insn->{$_} = 1 foreach (@flags);
	push @instructions, $insn;
}

while (<$fh>) {
	chomp;
	/^\s*(#.*)*$/ and next;
	die sprintf "invalid line %d" unless (/^\s*(.+?)\s+\[(.+?)\]\s*(.*)$/);
	processInsn( $1, $2, $3 );
}
close $fh;

open $fh, '>', 'OpCodes.pm' or die $!;

printf $fh <<"EOF"
#################################################
# automatically generated file. do not edit !!! #
#################################################

package Parse::Easy::Lexer::OpCodes;
use strict;
use warnings;
use base qw(Exporter);
our \@EXPORT_OK = qw(instructions);

my \@instructions = %s;

sub instructions { \\\@instructions }

1;
EOF
  , pp @instructions;

close $fh;
