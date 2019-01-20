#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy;
use strict;
use warnings;
use autodie;
use feature qw/say/;
use Parse::Easy::Parse::Parser;
use Config;

sub new {
	my ( $class, $file ) = @_;
	my $self = { file => $file, };
	bless $self, $class;
	$self;
}

sub opening {
	my ($self) = @_;
	my $arch = $Config{use64bitint} ? 'x64' : 'x86';
	print <<EOF;
##################################################
 Parse::Easy - Copyright (c) 2018  Mahdi Safsafi.
 Parse::Easy version : v1 alpha.
 Perl version        : $] ($arch).
##################################################


EOF
}

sub generate {
	my ($self) = @_;
	$self->opening();
	my $file   = $self->{file};
	my $string = '';
	local $/ = undef;
	open my $fh, '<', $file;
	$string = <$fh>;
	close $fh;
	printf "parsing file '%s'.\n",$file;
	my $parser = Parse::Easy::Parse::Parser->new();
	$parser->YYInput($string);
	my $grammar = $parser->Run();
	$grammar->process();
}
1;
