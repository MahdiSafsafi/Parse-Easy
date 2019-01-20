#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Closure.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Closure;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Token);
use Parse::Easy::Utils qw(sameItems);

sub new {
	my ( $class, $rule, $dotIndex, $items ) = @_;
	my $self  = $class->SUPER::new();
	my @items = @$items;
	$self->{rule}     = $rule;
	$self->{dotIndex} = $dotIndex;
	$self->{items}    = \@items;
	$self;
}

sub dotIndex {
	my ( $self, $value ) = @_;
	$self->{dotIndex} = $value // $self->{dotIndex};
}

sub rule {
	my ($self) = @_;
	$self->{rule};
}

sub items {
	my ($self) = @_;
	$self->{items};
}

sub ended {
	my ($self) = @_;
	$self->{dotIndex} >= scalar @{ $self->{items} };
}

sub clone {
	my ($self) = @_;
	Parse::Easy::Lexer::Closure->new( $self->{rule}, $self->{dotIndex}, $self->{items} );
}

sub nextClosure {
	my ($self) = @_;
	$self->ended() and return undef;
	my $next = $self->clone();
	$next->{dotIndex}++;
	$next;
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->{rule} == $that->{rule} &&         # same rule
	  $self->{dotIndex} == $that->{dotIndex} &&    # same dotIndex
	  sameItems( $self->{items}, $that->{items}, 1 )    # same items
}

sub toString {
	my ($self)   = @_;
	my $rule     = $self->{rule};
	my $dotIndex = $self->{dotIndex};
	my $count    = scalar @{ $self->{items} };
	my @data     = ();
	for my $i ( 0 .. $count - 1 ) {
		my $item = $self->{items}->[$i];
		$dotIndex == $i and push @data, ".";
		push @data, $item->toString();
	}
	$dotIndex >= $count and push @data, ".";
	sprintf "%s -> %s", $rule->{name}, join ' ', @data;
}
1;
