#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/State.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::State;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Token;
use Parse::Easy::Utils qw(sameItems);
our @ISA = qw(Parse::Easy::Token);

sub new {
	my ( $class, $kernel ) = @_;
	my $self = $class->SUPER::new();
	$self->buildStateFromKernel($kernel);
	$self;
}

sub index {
	my ( $self, $index ) = @_;
	if ( defined $index ) {
		$self->{index} = $index;
		$self->{name}  = "State$index";
	}
	$self->{index};
}

sub buildStateFromKernel {
	my ( $self, $kernel ) = @_;
	my @accepts = ();
	foreach my $closure ( @{ $kernel->{closures} } ) {
		$closure->ended() or next;
		push @accepts, $closure->{rule};
	}
	my @gotos = sort { $a->{target} - $b->{target} } @{ $kernel->{gotos} };
	$self->{gotos}   = \@gotos;
	$self->{accepts} = \@accepts;
}

sub sameGotos {
	my ( $self, $that ) = @_;
	scalar @{ $self->{gotos} } != scalar @{ $that->{gotos} } and return 0;
	for my $i ( 0 .. scalar @{ $self->{gotos} } - 1 ) {
		my $a = $self->{gotos}->[$i];
		my $b = $that->{gotos}->[$i];
		$a->{target} == $b->{target} or return 0;
		$a->{key}->same( $b->{key} ) or return 0;
	}
	1;
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->type() eq $that->type() &&    # same type
	  sameItems( $self->{accepts}, $that->{accepts}, 0 ) &&    # same accepted rules
	  sameGotos( $self, $that );
}

sub toString {
	my ($self) = @_;
	my @data = ();
	push @data, sprintf( "State %d:\n", $self->{index} );
	foreach my $accept ( @{ $self->{accepts} } ) {
		push @data, sprintf "ACCEPT %s\n", $accept->{name};
	}

	foreach my $goto ( @{ $self->{gotos} } ) {
		my $key    = $goto->{key};
		my $target = $goto->{target};
		push @data, sprintf "%s => %d\n", $key->toString(), $target->{index};
	}
	join( '', @data );
}

1;
