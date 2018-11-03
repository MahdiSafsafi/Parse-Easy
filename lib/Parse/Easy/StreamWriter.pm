#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/StreamWriter.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::StreamWriter;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Endian qw(unpackInteger);
use Carp;

sub new {
	my ( $class, $endian ) = @_;
	my $self = {
		endian => $endian,
		pos    => 0,
		data   => '',
	};
	bless $self, $class;
	$self;
}

sub size { $_[0]->{pos} }

sub pos {
	my ( $self, $value ) = @_;
	$self->{pos} = $value // $self->{pos};
}

sub bytes {
	my ($self) = @_;
	unpack "C*", $self->{data};
}

sub writeBytes {
	my ($self) = shift;
	vec( $self->{data}, $self->{pos}++, 8 ) = $_ foreach (@_);
}

sub writeString {
	my ( $self, $string ) = @_;
	$self->writeBytes( unpack "C*", pack "Z*", $string );
}

sub writeUnicode {
	my ( $self, $string ) = @_;
	my @chars = $string =~ /(.)/g;
	$self->writeInteger( ord $_, 2 ) foreach (@chars);
	$self->writeInteger( 0, 2 );
}

sub write8 {
	my ( $self, $value ) = @_;
	$self->writeBytes($value);
}

sub write16 {
	my ( $self, $value, $signed ) = @_;
	$self->writeInteger( $value, 2, $signed );
}

sub write32 {
	my ( $self, $value, $signed ) = @_;
	$self->writeInteger( $value, 4, $signed );
}

sub write64 {
	my ( $self, $value, $signed ) = @_;
	$self->writeInteger( $value, 8, $signed );
}

sub writeInteger {
	my ( $self, $value, $size, $signed ) = @_;
	$value // croak;
	$self->writeBytes( unpackInteger( $value, $size, $signed, $self->{endian} ) );
}

1;
