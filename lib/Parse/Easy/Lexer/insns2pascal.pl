#!/usr/bin/perl

#BEGIN_HEADER
#
# Module insns2pascal.pl Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

use strict;
use warnings;
use Parse::Easy::Lexer::OpCodes qw(instructions);
use feature qw(say);
use Data::Dump qw(pp);
use Storable qw(dclone);
use List::Util qw(min max);

my $tmp = instructions();
my $db  = [];
foreach my $insn (@$tmp) {
	$insn->{mnem} =~ /^(label|db|dw|dd|dq)$/ and next;
	$insn->{alias} and next;
	push @$db, dclone $insn;
}

my $maxPatternCount = 0;
my $maxArgCount     = 0;
my %valids          = ();
my @IID             = ();
my @PATTERNS        = ();
my @ARGS            = ();

sub registerType {
	my ( $types, $value, $prefix ) = @_;
	foreach my $item (@$types) {
		$item->{value} eq $value and return $item->{id};
	}
	push @$types,
	  my $item = {
		value => $value,
		id    => sprintf( "%s_%s", $prefix, uc $value ),
		index => scalar @$types,
	  };
	$item->{id};
}
registerType( \@IID,      'invalid', 'INSN' );
registerType( \@ARGS,     'NONE',    'ARG' );
registerType( \@PATTERNS, 'NONE',    'PAT' );

foreach my $insn (@$db) {
	$insn->{iid} = registerType( \@IID, $insn->{mnem}, 'INSN' );

	my @patterns = @{ $insn->{patterns} };
	my $opcode   = oct shift @patterns;
	$insn->{opcode} = $opcode;
	$valids{$opcode} = $insn;

	# patterns:
	my @newPatterns = ();
	push @newPatterns, registerType( \@PATTERNS, $_, 'PAT' ) foreach (@patterns);
	$insn->{patterns} = \@newPatterns;
	$maxPatternCount = max( $maxPatternCount, scalar @newPatterns );

	# arguments:
	my @newArgs = ();
	push @newArgs, registerType( \@ARGS, $_, 'ARG' ) foreach ( @{ $insn->{args} } );
	$insn->{args} = \@newArgs;
	$maxArgCount = max( $maxArgCount, scalar @newArgs );
}

my @instructions = ();
for my $i ( 0 .. 0xff ) {
	my $valid = $valids{$i};
	if ($valid) {
		push @instructions, $valid;
		next;
	}
	push @instructions,
	  {
		iid      => 'INSN_INVALID',
		opcode   => $i,
		args     => [],
		patterns => [],
	  };
}
my $file = $ARGV[0] // 'insns.inc';

open my $fh, '>', $file;
print $fh <<"EON";

// #################################################
// # automatically generated file. do not edit !!! #
// #################################################

// see $0.

EON

printf $fh "const\n";
printf $fh "  %-20s = %d;\n", 'MAX_ARG_COUNT',     $maxArgCount;
printf $fh "  %-20s = %d;\n", 'MAX_PATTERN_COUNT', $maxPatternCount;
printf $fh "\n";
printf $fh "  { instructions }\n";
printf $fh "  %-14s = %02d;\n", $_->{id}, $_->{index} foreach (@IID);
printf $fh "  { arguments }\n";
printf $fh "  %-10s = %02d;\n", $_->{id}, $_->{index} foreach (@ARGS);
printf $fh "  { patterns }\n";
printf $fh "  %-10s = %02d;\n", $_->{id}, $_->{index} foreach (@PATTERNS);
printf $fh "\n";

print $fh <<"EOR";
type 
  TInstructionDscrp = record 
    IID      : Integer;
    Args     : array [ 0 .. MAX_ARG_COUNT     -1 ] of Integer;
    Patterns : array [ 0 .. MAX_PATTERN_COUNT -1 ] of Integer;
  end;
  PInstructionDscrp = ^TInstructionDscrp;
  
EOR
printf $fh "const instructions : array [ 0 .. %d - 1 ] of TInstructionDscrp = (\n", scalar @instructions;

foreach my $i ( 0 .. @instructions - 1 ) {
	my $insn = $instructions[$i];
	my @args = @{ $insn->{args} };
	push @args, "ARG_NONE" while ( scalar @args < $maxArgCount );
	my $args = join( ', ', @args );

	my @patterns = @{ $insn->{patterns} };
	push @patterns, "PAT_NONE" while ( scalar @patterns < $maxPatternCount );
	my $patterns = join( ', ', @patterns );

	my $iid    = $insn->{iid};
	my $opcode = $insn->{opcode};
	my $comma  = $i == @instructions - 1 ? '' : ',';
	printf $fh "  {%02d} (IID: %-12s; Args: (%-20s); Patterns: (%s))%s\n", $opcode, $iid, $args, $patterns, $comma;
}
printf $fh ");\n";

close $fh;
