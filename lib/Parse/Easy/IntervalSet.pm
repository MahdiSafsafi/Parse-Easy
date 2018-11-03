#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/IntervalSet.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::IntervalSet;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
our @ISA = qw(Parse::Easy::Token);
use Parse::Easy::Token;
use Set::IntSpan;

sub makeInterval {
	my ($arg) = @_;
	ref($arg) eq __PACKAGE__ and return $arg;
	Parse::Easy::IntervalSet->new($arg);
}

sub new {
	my ($class) = shift;
	my $arg     = shift;
	my $self    = $class->SUPER::new();
	$self->{class} = $class;
	$self->{set} = defined $arg && ref($arg) eq 'Set::IntSpan' ? $arg : Set::IntSpan->new($arg);
	$self;
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->type() eq $that->type() && $self->{set}->equal( $that->{set} );
}

sub clone {
	my ($self) = @_;
	my $set = Set::IntSpan->new('');
	$set->copy( $self->{set} );
	$self->{class}->new($set);
}

sub empty {
	my ($self) = @_;
	$self->{set}->empty();
}

sub union {
	my ( $self, $that ) = @_;
	my $set = $self->{set}->union( $that->{set} );
	$self->{class}->new($set);
}

sub diff {
	my ( $self, $that ) = @_;
	my $set = $self->{set}->diff( $that->{set} );
	$self->{class}->new($set);
}

sub interSection {
	my ( $self, $that ) = @_;
	my $set = $self->{set}->intersect( $that->{set} );
	$self->{class}->new($set);
}

sub xor {
	my ( $self, $that ) = @_;
	my $set = $self->{set}->xor( $that->{set} );
	$self->{class}->new($set);
}

sub complement {
	my ( $self, $that ) = @_;
	my $set = $self->{set}->complement( $that->{set} );
	$self->{class}->new($set);
}

sub U {
	my ( $self, $that ) = @_;
	$self->{set}->U( $that->{set} );
	$self;
}

sub D {
	my ( $self, $that ) = @_;
	$self->{set}->D( $that->{set} );
	$self;
}

sub I {
	my ( $self, $that ) = @_;
	$self->{set}->I( $that->{set} );
	$self;
}

sub X {
	my ( $self, $that ) = @_;
	$self->{set}->X( $that->{set} );
	$self;
}

sub C {
	my ( $self, $that ) = @_;
	$self->{set}->C( $that->{set} );
	$self;
}

sub size {
	my ($self) = @_;
	$self->{set}->size();
}

sub min {
	my ($self) = @_;
	$self->{set}->min();
}

sub max {
	my ($self) = @_;
	$self->{set}->max();
}

sub sets {
	my ($self) = @_;
	my @sets = map { $self->{class}->new($_) } $self->{set}->sets();
}

sub toString {
	my ($self) = @_;
	$self->{set}->run_list();
}

1;
