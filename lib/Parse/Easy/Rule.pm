#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Rule.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Rule;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::NoTerm;
use Readonly;
our @ISA = qw(Parse::Easy::NoTerm);
use Parse::Easy::Utils qw(sameItems);

$Parse::Easy::Rule::EmptyString = '/*empty*/';

Readonly my $RF_NONE     => 0;
Readonly my $RF_ACCEPT   => 1;
Readonly my $RF_USER     => 2;
Readonly my $RF_FRAGMENT => 4;
Readonly my $RF_INTERNAL => 8;

my @flagsToString = (
	'ACCEPT'   => $RF_ACCEPT,
	'USER'     => $RF_USER,
	'FRAGMENT' => $RF_FRAGMENT,
	'INTERNAL' => $RF_INTERNAL,
);

sub new {
	my ( $class, $name, $rhss ) = @_;
	my $self = $class->SUPER::new($name);
	%$self = (
		%$self,
		(
			items      => $rhss,
			index      => undef,
			id         => undef,
			flags      => $RF_NONE,
			start      => 0,
			end        => 0,
			axiom      => 0,
			returnType => undef,
		)
	);
	$self;
}

sub returnType {
	my ( $self, $value ) = @_;
	$self->{returnType} = $value // $self->{returnType};
}

sub axiom {
	my ( $self, $value ) = @_;
	$self->{axiom} = $value // $self->{axiom};
}

sub start {
	my ( $self, $value ) = @_;
	$self->{start} = $value // $self->{start};
}

sub end {
	my ( $self, $value ) = @_;
	$self->{end} = $value // $self->{end};
}

sub accept {
	my ( $self, $value ) = @_;
	defined $value and $value
	  ? ( $self->{flags} |= $RF_ACCEPT )
	  : ( $self->{flags} &= ~$RF_ACCEPT );
	$self->{flags} & $RF_ACCEPT;
}

sub internal {
	my ( $self, $value ) = @_;
	defined $value and $value
	  ? ( $self->{flags} |= $RF_INTERNAL )
	  : ( $self->{flags} &= ~$RF_INTERNAL );
	$self->{flags} & $RF_INTERNAL;
}

sub fragment {
	my ( $self, $value ) = @_;
	defined $value and $value
	  ? ( $self->{flags} |= $RF_FRAGMENT )
	  : ( $self->{flags} &= ~$RF_FRAGMENT );
	$self->{flags} & $RF_FRAGMENT;
}

sub user {
	my ( $self, $value ) = @_;
	defined $value and $value
	  ? ( $self->{flags} |= $RF_USER )
	  : ( $self->{flags} &= ~$RF_USER );
	$self->{flags} & $RF_USER;
}

sub index {
	my ( $self, $value ) = @_;
	$self->{index} = $value // $self->{index};
}

sub id {
	my ( $self, $value ) = @_;
	$self->{id} = $value // $self->{id};
}

sub items {
	my ($self) = @_;
	my @clone = @{ $self->{items} };
	wantarray ? @clone : \@clone;
}

sub itemCount {
	my ($self) = @_;
	scalar @{ $self->{items} };
}

sub empty {
	my ($self) = @_;
	$self->itemCount();
}

sub same {
	my ( $self, $that ) = @_;
	$self == $that
	  || $self->type() eq $that->type() && sameItems( $self->{items}, $that->{items}, 1 );
}

sub clone {
	my ($self) = @_;
	my @items = @{ $self->{items} };
	my $clone = Parse::Easy::Rule->new( $self->{name}, \@items );
	$clone->{index} = $self->{index};
	$clone->{flags} = $self->{flags};
	$clone;
}

sub flagsToString {
	my ($self) = @_;
	$self->{flags} or goto end;
	my @data = ();
	for ( my $i = 0 ; $i < $#flagsToString ; ) {
		my ( $name, $flag ) = ( $flagsToString[ $i++ ], $flagsToString[ $i++ ] );
		$flag & $self->{flags} and push @data, $name;
	}
  end:
	join( ', ', @data );
}

sub toString {
	my ($self) = @_;
	my @data = ();
	push @data, $_->toString() foreach ( @{ $self->{items} } );
	my $data = join( ' ', @data );
	$data or $data = $Parse::Easy::Rule::EmptyString;
	sprintf "%s -> %s", $self->{name}, $data;
}

1;
