#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Grammar.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Grammar;
use strict;
use warnings;
use feature qw(say fc);
use Data::Dump qw(pp);
use Parse::Easy::Lexer;
use Parse::Easy::Parser;
use Parse::Easy::Wildcard;

sub new {
	my ($class) = @_;
	my $self = {
		name   => undef,
		lexer  => undef,
		parser => undef,
	};
	bless $self, $class;
	$self->{lexer}  = Parse::Easy::Lexer->new();
	$self->{parser} = Parse::Easy::Parser->new();
	$self;
}

sub processUse {
	my ( $self, $name, $args ) = @_;
	my $lexer     = $self->{lexer};
	my $parser    = $self->{parser};
	my $fcname    = lc $name;
	my %shortcuts = (
		'ascii'   => 'lexer::ascii',
		'unicode' => 'lexer::unicode',
		'lr1'     => 'parser::lr1',
		'glr'     => 'parser::glr',
	);
	exists $shortcuts{$fcname} and $fcname = $shortcuts{$fcname};
	my $lexerASCII = sub {
		$Parse::Easy::Wildcard::MIN = 0x00;
		$Parse::Easy::Wildcard::MAX = 0xff;
	};
	my $lexerUnicode = sub {
		$Parse::Easy::Wildcard::MIN = 0x0000;
		$Parse::Easy::Wildcard::MAX = 0xffff;
	};
	my $lexerCodePoint = sub {
		my ( $min, $max ) = @$args;
		defined $min and $Parse::Easy::Wildcard::MIN = $min;
		defined $max and $Parse::Easy::Wildcard::MAX = $max;
	};
	my $parserBaseClass = sub {
		my ($class) = @$args;
		$parser->{parentclassname} = $class;
	};
	my $parserUnits = sub {
		$parser->addUnit($_) foreach @$args;
	};
	my $parserGLR = sub {
		$parser->{parentunitname}  = 'Parse.Easy.Parser.GLR';
		$parser->{parentclassname} = 'TGLR';
	};
	my $parserLR1 = sub {
		$parser->{parentunitname}  = 'Parse.Easy.Parser.LR1';
		$parser->{parentclassname} = 'TLR1';
	};

	my %uses = (
		'lexer::codepoints' => $lexerCodePoint,
		'lexer::ascii'      => $lexerASCII,
		'lexer::unicode'    => $lexerUnicode,
		'parser::baseclass' => $parserBaseClass,
		'parser::glr'       => $parserGLR,
		'parser::lr1'       => $parserLR1,
		'parser::units'     => $parserUnits,
	);
	my $action = $uses{$fcname};
	unless ( defined $action ) {
		warn "unable to find package '$name'";
		return;
	}
	$action->();
}

sub process {
	my ($self) = @_;
	my $name   = $self->{name};
	my $lexer  = $self->{lexer};
	mkdir $name unless -d $name;
	chdir $name;
	$lexer->name("${name}Lexer");
	$lexer->process();

	my $parser = $self->{parser};
	$parser->{lexer} = $lexer;
	$parser->name("${name}Parser");
	$parser->process();

}
1;
