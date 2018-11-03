#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parser/State.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parser::State;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Token;
use Parse::Easy::Utils qw(sameItems);
our @ISA = qw(Parse::Easy::Token);

use Parse::Easy::Parser::Action;
my $ACTION_CLASS = 'Parse::Easy::Parser::Action';

sub new {
	my ( $class, $kernel ) = @_;
	my $self = $class->SUPER::new();
	$self->index( $kernel->{index} );
	$self->{gotos} = [];
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

sub addAction {
	my ( $self, $key, $action ) = @_;
	foreach my $item ( @{ $self->{gotos} } ) {
		if ( $item->{key}->same($key) ) {
			push @{ $item->{actions} }, $action;
			return 0;
		}
	}
	push @{ $self->{gotos} },
	  {
		key     => $key,
		actions => [$action]
	  };
}

sub buildStateFromKernel {
	my ( $self, $kernel ) = @_;
	$self->{closures}=$kernel->{closures};
	foreach my $item ( @{ $kernel->{gotos} } ) {
		my $key    = $item->{key};
		my $target = $item->{target};
		my $action = undef;
		if ( $key->type() eq 'term' ) {
			$action = $ACTION_CLASS->new( 'SHIFT', $target );
		}
		else {
			$action = $ACTION_CLASS->new( 'JUMP', $target );
		}
		$self->addAction( $key, $action );
	}
	foreach my $closure ( @{ $kernel->{closures} } ) {
		my $rule = $closure->{rule};
		if ( $closure->ended() || $rule->{items}->[0]->type() eq 'epsilon' ) {
			foreach my $lookAhead ( @{ $closure->{lookAheads} } ) {
				my $action = $ACTION_CLASS->new( 'REDUCE', $rule );
				$self->addAction( $lookAhead, $action );
			}
		}
	}
}

sub toString {
	my ($self) = @_;
	my @data = ();
	push @data, sprintf "State %d:", $self->index();
	foreach my $closure(@{$self->{closures}}){
		push @data, $closure->toString();
	}
	
	foreach my $item ( @{ $self->{gotos} } ) {
		my $key   = $item->{key};
		my $array = $item->{actions};
		my $conflict = scalar @$array > 1;
		$conflict and push @data,"conflict:";
		foreach my $action (@$array) {
			if ( $action->{type} eq 'SHIFT' ) {
				push @data, sprintf "  %s shift and goto %d", $key->toString(), $action->{value}->{index};
			}
			elsif ( $action->{type} eq 'JUMP' ) {
				push @data, sprintf "  %s and goto %d", $key->toString(), $action->{value}->{index};
			}
			elsif ( $action->{type} eq 'REDUCE' ) {
				push @data, sprintf "  %s and reduce using rule %s (%d)", $key->toString(), $action->{value}->{name},$action->{value}->{index}
			}
		}
		$conflict and push @data,"";
	}
	my $data = join("\n",@data);
}
1;
