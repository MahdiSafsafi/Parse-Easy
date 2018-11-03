#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parser/Exporter.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parser::Exporter;
use strict;
use warnings;
use Parse::Easy::StreamWriter;
use Parse::Easy::Target::Pascal::Utils qw/generateRes/;
use Parse::Easy::Version;

sub new {
	my ( $class, $parser ) = @_;
	my $self = {
		parser => $parser,
		writer => Parse::Easy::StreamWriter->new(0)
	};
	bless $self, $class;
	$self;
}

sub outputState {
	my ( $self, $state ) = @_;
	my $writer = $self->{writer};
	my $parser = $self->{parser};
	my $lexer  = $parser->{lexer};
	$writer->write32( $state->{index} );
	my @terms   = ();
	my @noterms = ();
	foreach my $goto ( @{ $state->{gotos} } ) {
		my $key = $goto->{key};
		if ( $key->type() eq 'term' ) {
			push @terms, $goto;
		}
		else {
			push @noterms, $goto;
		}
	}
	$writer->write32( scalar @terms );
	$writer->write32( scalar @noterms );
	foreach my $goto ( @terms, @noterms ) {
		my $key   = $goto->{key};
		my $index = undef;
		if ( $key->type() eq 'term' ) {
			$index = $lexer->{tokens}->{ $key->name() };
		}
		else {
			$index = $parser->{tokens}->{ $key->name() };
		}
		my @actions = @{ $goto->{actions} };

		$writer->write32($index);
		$writer->write32( scalar @actions );
		foreach my $action (@actions) {
			my $type = { SHIFT => 1, REDUCE => 2, JUMP => 3 }->{ $action->{type} };
			$writer->write32($type);
			$writer->write32( $action->{value}->{index} );
		}
	}
}

sub getRuleItemCount {
	my ($rule) = @_;
	my $result = 0;
	foreach my $item ( @{ $rule->{items} } ) {
		$item->type() ne 'epsilon' and $result++;
	}
	$result;
}

sub outputRules {
	my ( $self, $rule ) = @_;
	my $parser = $self->{parser};
	my $writer = $self->{writer};
	foreach my $rule ( @{ $parser->{allRules} } ) {
		my $flags = 0;
		$rule->accept() and $flags |= 1;
		my $actionIndex = -1;
		$rule->{action} and $actionIndex = $rule->{action}->{index};
		$writer->write32( $rule->id() );
		$writer->write32($flags);
		$writer->write32( getRuleItemCount($rule) );
		$writer->write32($actionIndex);
	}
}

sub generate {
	my ($self) = @_;
	printf "    - initializing data...\n";
	my $parser = $self->{parser};
	my $writer = $self->{writer};
	$writer->write32($Parse::Easy::Version::Major);
	$writer->write32($Parse::Easy::Version::Minor);
	$writer->write32( scalar @{ $parser->{states} } );
	$writer->write32( scalar @{ $parser->{allRules} } );
	$writer->write32( scalar keys %{ $parser->{lexer}->{tokens} } );
	printf "    - outputing rules...\n";
	$self->outputRules();
	printf "    - outputing states...\n";
	$self->outputState($_) foreach ( @{ $parser->{states} } );
	printf "    - generating binary file...\n";

	my @bytes = $writer->bytes();
	my $file  = $parser->{binfile};
	$self->{parser}->{binary} = $file;
	open my $fh, '>:raw', $file;
	print $fh pack "C", $_ foreach (@bytes);
	close $fh;
	printf "    - generating resource file...\n";
	generateRes( $parser->{name}, $parser->{rcfile}, $parser->{resfile}, $parser->{binfile} );
}
1;
