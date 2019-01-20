#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parser/Closure.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parser::Closure;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Token);
use Parse::Easy::Utils qw(sameItems);

sub new {
	my ( $class, $rule, $dotIndex ) = @_;
	my $self = $class->SUPER::new();
	$self->{rule}       = $rule;
	$self->{dotIndex}   = $dotIndex;
	$self->{lookAheads} = [];
	$self->computeLookAheads();
	$self;
}

sub computeLookAheads {
	my ($self)  = @_;
	my $rule    = $self->{rule};
	my $name    = $rule->name();
	my $grammar = $rule->{grammar};
	my @follows = @{ $grammar->{follows}->{$name} };
	$self->{lookAheads}=\@follows;
}

sub ended {
	my ($self) = @_;
	$self->{dotIndex} >= scalar @{ $self->{rule}->{items} };
}

sub clone {
	my ($self) = @_;
	Parse::Easy::Parser::Closure->new( $self->{rule}, $self->{dotIndex} );
}

sub nextClosure {
	my ($self) = @_;
	$self->ended() and return undef;
	my $item = $self->{rule}->{items}->[ $self->{dotIndex} ];
	$item->type() eq 'epsilon' and return undef;
	my $next = $self->clone();
	$next->{dotIndex}++;
	$next;
}

sub sameLookAheads {
	my ( $a, $b ) = @_;
	scalar @$a != scalar @$b and return 0;
	for my $i ( 0 .. scalar @$a - 1 ) {
		my $item1 = $a->[$i];
		my $found = 0;
		for my $j ( 0 .. scalar @$b - 1 ) {
			my $item2 = $b->[$j];
			if ( $item1->same($item2) ) {
				$found++;
				last;
			}
		}
		$found || return 0;
	}
	1;
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->{rule} == $that->{rule} &&         # same rule
	  $self->{dotIndex} == $that->{dotIndex} &&    # same dotIndex
	  sameLookAheads( $self->{lookAheads}, $that->{lookAheads} );
}

sub toString {
	my ($self)     = @_;
	my $rule       = $self->{rule};
	my $dotIndex   = $self->{dotIndex};
	my $count      = scalar @{ $self->{rule}->{items} };
	my @lookAheads = ();
	foreach my $lookahead ( @{ $self->{lookAheads} } ) {
		push @lookAheads, $lookahead->toString();
	}
	my $lookAheads = join( ', ', @lookAheads );
	my @data = ();
	for my $i ( 0 .. $count - 1 ) {
		my $item = $self->{rule}->{items}->[$i];
		$dotIndex == $i and push @data, ".";
		push @data, $item->toString();
	}
	$dotIndex >= $count and push @data, ".";
	sprintf "%s -> %s ; [%s]", $rule->{name}, join( ' ', @data ), $lookAheads;
}
1;
