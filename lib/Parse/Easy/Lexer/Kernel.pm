#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer/Kernel.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer::Kernel;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Token;
use Parse::Easy::Utils qw(sameItems);
our @ISA = qw(Parse::Easy::Token);

sub new {
	my ( $class, $grammar, $closures ) = @_;
	my @drivers = @$closures;
	my $index   = scalar @{ $grammar->{kernels} };
	my $self    = $class->SUPER::new();
	push @{ $grammar->{kernels} }, $self;
	%$self = (
		%$self,
		(
			name     => sprintf( "Kernel%d", $index ),
			index    => $index,
			grammar  => $grammar,
			drivers  => \@drivers,
			closures => $closures,
			gotos    => [],
		)
	);
	$self;
}

sub addGoTo {
	my ( $self, $key, $target ) = @_;
	push @{ $self->{gotos} },
	  {
		key    => $key,
		target => $target,
	  };
}

sub toString {
	my ($self) = @_;
	my @data = ();
	push @data, sprintf( "Kernel %d:\n", $self->{index} );
	push @data, sprintf( "%s\n", $_->toString() ) foreach ( @{ $self->{drivers} } );
	push @data, "\n";
	foreach my $closure(@{$self->{closures}}){
		$closure->ended() or next;
		push @data,sprintf "ACCEPT %s\n",$closure->{rule}->{name};
	}
	
	foreach my $goto(@{$self->{gotos}}){
		my $key=$goto->{key};
		my $target = $goto->{target};
		push @data,sprintf "%s => %d\n",$key->toString(), $target->{index};
	}
	join( '', @data );
}
