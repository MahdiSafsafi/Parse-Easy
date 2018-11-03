#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Instruction.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Instruction;
use strict;
use warnings;
use Readonly;
use feature qw(say);
use Data::Dump qw(pp);
use List::Util qw(min max);
use Parse::Easy::Lexer::Compiler::Utils qw(sizeOfInteger);
use Parse::Easy::Endian qw(unpackInteger);

my %char2size = (
	b => 8,
	w => 16,
	d => 32,
);

sub new {
	my ( $class, $compiler, $name ) = @_;
	my $entries = $compiler->{isa}->{$name};
	$entries or die sprintf "unkown instruction '%s'", $name;
	my ( $maxsize, $maybeRelative ) = ( 0, 0 );
	foreach my $entry (@$entries) {
		$maxsize = max( $maxsize, $entry->{maxsize} );
		$maybeRelative |= $entry->{relative};
	}
	my $self = {
		compiler      => $compiler,
		endian        => $compiler->{endian},
		name          => $name,
		index         => undef,
		encoding      => undef,
		address       => undef,
		entry         => undef,
		maxsize       => $maxsize,
		size          => undef,
		entries       => $entries,
		maybeRelative => $maybeRelative,
		isLabel       => $name eq 'label',
		operands      => [],
		of            => 0,
	};
	bless $self, $class;
	$self;
}
sub maybeRelative { $_[0]->{maybeRelative} }
sub isLabel       { $_[0]->{isLabel} }
sub maxSize       { $_[0]->{maxsize} }
sub size          { $_[0]->{size} }
sub clear         { $_[0]->{encoding} = undef }

sub address {
	my ( $self, $value ) = @_;
	$self->{address} = $value // $self->{address};
}

sub entry {
	my ( $self, $value ) = @_;
	$self->{entry} = $value // $self->{entry};
}

sub index {
	my ( $self, $value ) = @_;
	$self->{index} = $value // $self->{index};
}

sub addOperand {
	my ( $self, $value ) = @_;
	push @{ $self->{operands} }, $value;
}

sub normalize {
	my ( $self, $operand, $template ) = @_;
	my $endian = $self->{endian};
	if ( $template =~ /^rel(\d+)$/ ) {
		my $dsz    = $1;
		my $from   = $self->address();
		my $to     = $operand->address();
		my $offset = $to - $from;
		my $asz    = sizeOfInteger( $offset, 1 );
		$asz > $dsz and return 0;
		my @bytes = unpackInteger( $offset, $dsz / 8, 1, $endian );
		$self->{$template} = \@bytes;
	}
	elsif ( $template =~ /^imm(\d+)$/ ) {
		my $dsz = $1;
		my $asz = sizeOfInteger( $operand, 1 );
		$asz > $dsz and return 0;
		my @bytes = unpackInteger( $operand, $dsz / 8, 1, $endian );
		$self->{$template} = \@bytes;
	}
	elsif ( $template =~ /^uimm(\d+)$/ ) {
		$operand < 0 and return 0;
		my $dsz = $1;
		my $asz = sizeOfInteger( $operand, 0 );
		$asz > $dsz and return 0;
		my @bytes = unpackInteger( $operand, $dsz / 8, 0, $endian );
		$self->{$template} = \@bytes;
	}
	elsif ( $template =~ /^r(\d+)$/ ) {
		return $operand eq $template;
	}
	elsif ( $template =~ /^rr$/ ) {
		$operand =~ /^r(\d+)$/ or return 0;
		$1 < 7 or return 0;
		$self->{mr} |= $1 << 5;
	}
	elsif ( $template =~ /^rm$/ ) {
		$operand =~ /^r(\d+)$/ or return 0;
		$1 < 7 or return 0;
		$self->{mr} |= $1;
	}
	elsif ( $template =~ /^offset$/ ) {
		my $mr = $self->{mr};
		if ($operand) {
			my $value = $operand;
			my $power = 8;
			for my $i (qw/64 32 16 8 4 2 1/) {
				$power--;
				unless ( $value % $i ) {
					$value /= $i;
					last;
				}
			}
			$power < 8 or die "invalid power";
			my $asz = sizeOfInteger( $value, 0 );
			$mr |= { 8 => 0, 16 => 1, 32 => 2, 64 => 3 }->{$asz};
			$mr |= $power << 2;
			my @bytes = unpackInteger( $value, $asz / 8, 0, $endian );
			$self->{offset} = \@bytes;
			$self->{mr}     = $mr;
		}
		else {
			$self->{offset} = [];
		}
	}
	else {
		die "unhandled '$template'";
	}
	1;
}

sub encodeEntry {
	my ( $self, $entry ) = @_;
	$self->{mr}     = 0;
	$self->{offset} = undef;
	my @templates = @{ $entry->{args} };
	my @patterns  = @{ $entry->{patterns} };
	my @operands  = @{ $self->{operands} };
	@operands != @templates and return undef;

	for my $i ( 0 .. @templates - 1 ) {
		my $operand  = $operands[$i];
		my $template = $templates[$i];
		my $result   = $self->normalize( $operand, $template );
		$result or return undef;
	}
	my @encoding = ();
	for my $i ( 0 .. @patterns - 1 ) {
		local $_ = $patterns[$i];
		if (/^0x[0-9a-f]{2}/i) {
			push @encoding, oct $_;
		}
		elsif (/^o([bwd])$/) {
			my %rels = ( ob => 'rel8', ow => 'rel16', od => 'rel32' );
			my $rel = $rels{$_};
			push @encoding, @{ $self->{$rel} };
		}
		elsif (/^[iu](\d+)$/) {
			my %imms = (
				i8  => 'imm8',
				i16 => 'imm16',
				i32 => 'imm32',
				u8  => 'imm8',
				u16 => 'uimm16',
				u32 => 'uimm32'
			);
			my $imm = $imms{$_};
			push @encoding, @{ $self->{$imm} };
		}
		elsif (/^mr$/) {
			push @encoding, $self->{mr};
		}
		elsif (/^mf$/) {
			push @encoding, $self->{mr};
			$self->{offset} and push @encoding, @{ $self->{offset} };
		}
		else {
			die "unable to handle pattern '$_'";
		}
	}
	\@encoding;
}

sub doEncode {
	my ($self) = @_;
	my $encoding = undef;
	for my $i ( 0 .. scalar @{ $self->{entries} } - 1 ) {
		my $entry = $self->{entries}->[$i];
		$encoding = $self->encodeEntry($entry);
		defined $encoding and $self->entry($entry) and last;
	}
	$encoding or die sprintf "unable to encode instruction '%s'", $self->{name};
	$encoding;
}

sub encoding {
	my ( $self, $value ) = @_;
	if ( defined $value ) {
		$self->{encoding} = $value;
		$self->{size}     = scalar @$value;
	}
	$self->{encoding};
}

sub encode {
	my ($self) = @_;
	$self->encoding( $self->doEncode() );
}

1;
