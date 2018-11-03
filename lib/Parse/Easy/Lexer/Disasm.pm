#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Disasm.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Disasm;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Lexer::OpCodes qw(instructions);
my $db = instructions();
my @tables = map { { opcode => $_, entries => undef } } 0x00 .. 0xff;
foreach my $insn (@$db) {
	my @patterns = @{ $insn->{patterns} };
	my $first    = shift @patterns // next;
	$first =~ /^0x[a-f0-9]{2}$/i or next;
	my $op = oct $first;
	push @{ $tables[$op]->{entries} }, $insn;
}

my %char2size = (
	b => 8,
	w => 16,
	d => 32,
);

no warnings 'portable';

sub readInteger {
	my ( $bytes, $index, $size, $signExtend ) = @_;
	my @bytes = ();
	push @bytes, $bytes->[$_] for ( $index .. ( $index + $size ) - 1 );
	my $value = 0;
	@bytes = reverse @bytes;
	foreach (@bytes) {
		$value <<= 8;
		$value |= $_;
	}
	if ($signExtend) {
		my $pos = 1 << $size * 8 - 1;
		if ( $value & $pos ) {
			my $mask = { 1 => 0xff, 2 => 0xffff, 4 => 0xffffffff, 8 => 0xffffffffffffffff }->{$size};
			$value = ( -1 & ~$mask ) | $value;
			$value = unpack 's', pack 'S', $value;
		}
	}
	$value;
}

sub decodePattern {
	my ( $bytes, $offset, $template, $out ) = @_;
	my @encoding = ();
	my $pc       = $offset;
	foreach my $pattern (@$template) {
		if ( $pattern =~ /^0x[a-f0-9]{2}$/i ) {
			my $opcode = oct $pattern;
			my $value  = $bytes->[$offset] // return 0;
			$opcode != $value and return 0;
			$offset++;
		}
		elsif ( $pattern =~ /^([ui])(\d+)$/ ) {
			my $size       = $2 / 8;
			my $signExtend = ( $1 eq 'i' );
			my $imm        = readInteger( $bytes, $offset, $size, $signExtend );
			push @encoding, { pattern => $pattern, value => $imm };
			$offset += $size;
		}
		elsif ( $pattern =~ /^[o]([bwd])$/ ) {
			my $size = $char2size{$1} / 8;
			my $imm = readInteger( $bytes, $offset, $size, 1 );
			push @encoding, { pattern => $pattern, value => $imm };
			$offset += $size;
		}
		elsif ( $pattern eq 'of' ) {
			my $value = $bytes->[$offset];
			$offset++;
			my $imm = 0;
			if ($value) {
				my $size = { 0 => 0, 1 => 1, 2 => 2, 3 => 4 }->{ $value & 3 };
				my $power = $value >> 2;
				$imm = readInteger( $bytes, $offset, $size );
				$offset += $size;
			}
			push @encoding, { pattern => $pattern, value => $imm };
		}
		else {
			die "unkown pattern '$pattern'";
		}
	}
	$out and @$out = @encoding;
	$offset - $pc;
}

sub stringify {
	my ( $insn, $addresses ) = @_;
	my @args     = ();
	my @encoding = @{ $insn->{encoding} };
	my $find     = sub {
		my ($expression) = @_;
		foreach my $item (@encoding) {
			$item->{taken} and next;
			if ( $item->{pattern} =~ $expression ) {
				$item->{taken} = 1;
				return $item->{value};
			}
			die "unable to find expression '$expression'";
		}
	};
	my @comment = ();
	foreach my $arg ( @{ $insn->{entry}->{args} } ) {
		local $_ = $arg;
		if (/^r(\d+)$/) {
			push @args, $_;
		}
		elsif (/^[u]*imm(\d+)$/) {
			my $imm = $find->(qr/^[ui]\d+$/);
			push @args, $imm;
		}
		elsif (/^rel(\d+)$/) {
			my $rel = $find->(qr/^o[bwd]$/);
			push @args, $rel;
			my $target = $insn->{address} + $rel;
			my $comment = sprintf "0x%08x", $target;
			!exists $addresses->{$target} and $comment .= ' ??';
			push @comment, $comment;
		}
		elsif (/^offset$/) {
			my $offset = $find->(qr/^of$/);
			push @args, $offset;
		}
		else {
			die "unable to handle argument '$_'";
		}
	}
	my $args = join( ', ', @args );
	my $string = $insn->{entry}->{mnem};
	if ( $args ne '' ) {
		$string .= '  ' . $args;
	}
	my $comment = join( ' ; ', @comment );
	$comment ne '' and $comment = "// $comment";
	$insn->{comment} = $comment;
	$insn->{syntax}  = $string;
}

sub disasm {
	my ($bytes)   = @_;
	my $i         = 0;
	my @insns     = ();
	my %addresses = ();
	while (1) {
		my $address = $i;
		my $opcode  = $bytes->[$i] // last;
		my $entries = $tables[$opcode]->{entries};
		defined $entries or die "undefined instruction";
		my $encoding = [];
		my $matched  = undef;
		my $size     = 0;
		foreach my $entry ( @{$entries} ) {
			$size     = 0;
			$encoding = [];
			$size     = decodePattern( $bytes, $i, $entry->{patterns}, $encoding ) or next;
			$matched  = $entry;
			last;
		}
		$i += $size;
		$matched or die "undefined instruction";
		my @bytecode = ();
		push @bytecode, $bytes->[$_] for ( $address .. $i - 1 );
		@bytecode = map { sprintf "%02x", $_ } @bytecode;
		my $bytecode = join( ' ', @bytecode );
		my $insn = { address => $address, bytecode => $bytecode, entry => $matched, encoding => $encoding };
		$addresses{$address}++;
		push @insns, $insn;
	}
	foreach (@insns) {
		stringify( $_, \%addresses );
		my $comment = $_->{comment};
		printf "0x%08x  %-15s  %s %s\n", $_->{address}, $_->{bytecode}, $_->{syntax}, $comment;
	}
}
