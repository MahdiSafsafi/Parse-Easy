#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Compiler.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Compiler;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Storable qw(freeze);
use Digest::MD5 qw(md5_hex);
use List::Util qw(min max);
use Parse::Easy::Lexer::OpCodes qw(instructions);
use Parse::Easy::Lexer::Instruction;
use Parse::Easy::Lexer::Compiler::Utils qw(sizeOfInteger);
use Parse::Easy::Lexer::Disasm;
use Parse::Easy::StreamWriter;
use Parse::Easy::Target::Pascal::Utils qw/generateRes/;
use Compress::Zlib qw(memGzip memGunzip);
use Parse::Easy::Version;

# load vm instructions:
my %instructions = ();
my $db           = instructions();
push @{ $instructions{ $_->{mnem} } }, $_ foreach (@$db);

# lazy access:
my $INSTRUCTION_CLASS   = 'Parse::Easy::Lexer::Instruction';
my $STREAM_WRITER_CLASS = 'Parse::Easy::StreamWriter';

sub new {
	my ( $class, $lexer ) = @_;
	my $self = {
		lexer    => $lexer,
		insns    => [],
		endian   => 0,
		bytecode => $STREAM_WRITER_CLASS->new(0),
		memory   => $STREAM_WRITER_CLASS->new(0),
		isa      => \%instructions,
		ruleinfo => undef,
	};
	bless $self, $class;
	$self;
}

sub labelOfState {
	my ( $self, $state ) = @_;
	$state->{label} = $state->{label} // $self->newInsn( 'label', [], 0 );
}

sub getSetsElementSize {
	my ( $self, $sets ) = @_;
	my $size = 0;
	for my $i ( 0 .. @$sets - 1 ) {
		my $set = $sets->[$i];
		my ( $min, $max ) = ( $set->min(), $set->max() );
		my $diff = $max - $min;
		$size = max( $size, sizeOfInteger( $min, 0 ), sizeOfInteger( $diff, 0 ) );
	}
	$size / 8;
}

sub registerSets {
	my ( $self, $sets ) = @_;
	my $checksum = md5_hex( freeze($sets) );
	my $memory   = $self->{memory};
	exists $self->{memoryCheckSums}->{$checksum}
	  and return $self->{memoryCheckSums}->{$checksum};

	$memory->write32( scalar @$sets );
	my $pos = $memory->pos();

	for my $i ( 0 .. @$sets - 1 ) {
		my $set = $sets->[$i];
		$memory->writeInteger( $set->min(), 4, 1 );
		$memory->writeInteger( $set->max(), 4, 1 );
	}
	$self->{memoryCheckSums}->{$checksum} = $pos;
	$pos;
}

sub compileState {
	my ( $self, $state ) = @_;
	$self->addInsn( $self->labelOfState($state) );
	$self->newInsn( 'ststart', [], 1 );
	$self->newInsn( 'setstate', [ $state->{index} ], 1 );
	if ( $state->{accepts} && @{ $state->{accepts} } ) {
		$self->newInsn( 'forget', [], 1 );
		foreach my $accept ( @{ $state->{accepts} } ) {
			my $ruleIndex = $accept->{index};
			my $next = $self->newInsn( 'label', [], 0 );
			if ( $accept->start() ) {
				$self->newInsn( 'isatx', [0],     1 );
				$self->newInsn( 'bneq',  [$next], 1 );
			}
			unless ( $accept->{anysection} ) {
				my $sections = $accept->{sections};
				my @sets     = $sections->sets();
				my $setIndex = $self->registerSets( \@sets );

				$self->newInsn( 'inrange', [ 'r1', $setIndex ], 1 );
				$self->newInsn( 'bneq', [$next], 1 );
			}
			if ( $accept->end() ) {
				$self->newInsn( 'isatx', [1],     1 );
				$self->newInsn( 'bneq',  [$next], 1 );
			}

			$self->newInsn( 'mark', [$ruleIndex], 1 );
			$self->addInsn($next);
		}
	}
	if ( @{ $state->{gotos} } ) {
		$self->newInsn( 'peek', [], 1 );
		foreach my $goto ( @{ $state->{gotos} } ) {
			my $next     = $self->newInsn( 'label', [], 0 );
			my $key      = $goto->{key};
			my $target   = $goto->{target};
			my @sets     = $key->sets();
			my $setIndex = $self->registerSets( \@sets );
			$self->newInsn( 'inrange', [ 'r0', $setIndex ], 1 );
			$self->newInsn( 'bneq',    [$next],                          1 );
			$self->newInsn( 'advance', [],                               1 );
			$self->newInsn( 'call',    [ $self->labelOfState($target) ], 1 );
			$self->newInsn( 'ret',     [],                               1 );
			$self->addInsn($next);
		}
	}
	$self->newInsn( 'ret',   [], 1 );
	$self->newInsn( 'stend', [], 1 );
}

sub emit {
	my ( $self, $bytes ) = @_;
	my $bytecode = $self->{bytecode};
	$bytecode->writeBytes(@$bytes);
}

sub newInsn {
	my ( $self, $name, $operands, $add ) = @_;
	my $insn = $INSTRUCTION_CLASS->new( $self, $name );
	$operands and $insn->addOperand($_) foreach (@$operands);
	$add and $self->addInsn($insn);
	$insn;
}

sub addInsn {
	my ( $self, $insn ) = @_;
	$insn->index( scalar @{ $self->{insns} } );
	push @{ $self->{insns} }, $insn;
	$insn;
}

sub translate {
	my ($self) = @_;

	# first give all instructions a probability address.
	my $address   = 0;
	my @relatives = ();
	foreach my $insn ( @{ $self->{insns} } ) {
		$insn->address($address);

		# for no-relative instructions, the encoder engine
		# is smart enough to choose the best and shortest
		# instruction's length.
		# however, relative instructions depend on encoding
		# of others instructions, so the encoder engine
		# is unable to decide which instruction to use (8-bit/16-bit/32-bit).
		# so in order to generate shortest instruction's lenght for relative-instructions,
		# we need to encode them later (after encoding all no relative-instructions).
		if ( $insn->maybeRelative() ) {

			$address += $insn->maxSize();
			push @relatives, $insn;
		}
		else {
			$insn->encode();
			$address += $insn->size();
		}
	}

	# now we encode relative instructions
	# the bellow algorithm will generate the shortest
	# relative instruction's length.
	my ( $depth, $notDone ) = (0);
  encodeRelatives:
	$depth++;
	$notDone = 0;    # assume everything is good.
	foreach my $insn (@relatives) {
		my $maxSize = $insn->size() // $insn->maxSize();
		$insn->encode();
		my $size = $insn->size();
		my $diff = $maxSize - $size;
		$diff or next;    # diff = 0 => no need to fix instruction address.
		$diff < 0 and die "diff < 0 => this can't be happen !!!";
		$notDone++;
		my $i = $insn->{index};

		# fix address for all instruction that come after a relative-instruction.
		for my $j ( $i + 1 .. @{ $self->{insns} } - 1 ) {
			my $next = $self->{insns}->[$j];
			$next->address( $next->address() - $diff );
		}
	}
	$notDone and goto encodeRelatives;

	foreach my $insn ( @{ $self->{insns} } ) {
		my $encoding = $insn->encoding();
		$self->emit($encoding);
	}

	# my @bytes = unpack "C*", $self->{bytecode};
	# Parse::Easy::Lexer::Disasm::disasm( \@bytes );
}

sub verbosity {
	my ($self) = @_;
	printf "\n\n\n\n";
	foreach my $insn ( @{ $self->{insns} } ) {
		my $name = $insn->{name};
		my @args = ();
		if ( $name =~ /^(call|bneq)$/ ) {
			push @args, $insn->{operands}->[0]->{address};
			my $offset = $insn->{operands}->[0]->address() - $insn->address();

			push @args, $insn->address() + $offset;
			push @args, $offset;
		}
		my $args = join( ', ', @args );
		my @encoding = map { sprintf "0x%02x", $_ } @{ $insn->{encoding} };
		my $encoding = join( ' ', @encoding );
		printf "%04d  0x%08x  %-15s  %-8s  %s\n", $insn->index(), $insn->address(), $encoding, $name, $args;
	}

}

sub generateBinary {
	my ($self) = @_;
	my ( $memory, $bytecode ) = ( $self->{memory}, $self->{bytecode} );
	my $program = $STREAM_WRITER_CLASS->new( $self->{endian} );

	$program->write32($Parse::Easy::Version::Major);
	$program->write32($Parse::Easy::Version::Minor);
	$program->write32( $memory->size() );
	$program->write32( $bytecode->size() );
	$program->write32( scalar @{ $self->{lexer}->{rules} } );
	$program->write32( $self->{ruleinfo} );
	$program->writeBytes( $memory->bytes() );
	$program->writeBytes( $bytecode->bytes() );
	my @bytes = $program->bytes();
	my $file = $self->{lexer}->{binfile};
	open my $fh, '>:raw', $file;
	print $fh pack "C", $_ foreach (@bytes);
	close $fh;
}


sub outputRules {
	my ($self) = @_;
	my $lexer  = $self->{lexer};
	my $memory = $self->{memory};
	my $pos    = $memory->pos();
	for my $i ( 0 .. @{ $lexer->{rules} } - 1 ) {
		my $rule  = $lexer->{rules}->[$i];
		my $name  = $rule->name;
		my $index = $rule->index;
		$i == $index or die "invalid index.";
		my $id          = $rule->id;
		my $actionIndex = -1;
		$rule->{action} and $actionIndex = $rule->{action}->index();
		$memory->writeInteger( $id,          4, 1 );
		$memory->writeInteger( $actionIndex, 4, 1 );
	}
	$self->{ruleinfo} = $pos;
}

sub compile {
	my ($self) = @_;
	my $lexer = $self->{lexer};
	printf "    - initializing vm instructions...\n";
	$self->newInsn( 'vmstart', [], 1 );
	my $s0 = $self->newInsn( 'label', [], 0 );
	$self->newInsn( 'call',  [$s0], 1 );
	$self->newInsn( 'vmend', [],    1 );
	$self->addInsn($s0);
	printf "    - compiling vm states...\n";
	$self->compileState($_) foreach ( @{ $lexer->{states} } );
	printf "    - translating instructions...\n";
	$self->translate();
	printf "    - outputing rules data...\n";
	$self->outputRules();
	printf "    - generating binary file...\n";
	$self->generateBinary();
	printf "    - generating resource file...\n";
	generateRes($lexer->{name},$lexer->{rcfile},$lexer->{resfile}, $lexer->{binfile});
}

1;
