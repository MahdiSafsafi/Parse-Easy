#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Target/Pascal/Parser.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Target::Pascal::Parser;
use strict;
use warnings;
use autodie;
use Parse::Easy::Target::Pascal::Header qw(get_header);
my $header = get_header();

sub new {
	my ( $class, $parser ) = @_;
	my $self = { parser => $parser, };
	bless $self, $class;
	$self;
}

sub generate {
	my ($self)          = @_;
	my $parser          = $self->{parser};
	my $name            = $parser->{name};
	my $parentunitname  = $parser->{parentunitname};
	my $parentclassname = $parser->{parentclassname};
	my $classname       = $parser->{classname};
	my $unitname        = $parser->{unitname};
	my $unitfile        = $parser->{unitfile};
	my $resfile         = $parser->{resfile};
	my @actions         = ();
	foreach my $rule ( @{ $parser->{allRules} } ) {
		my $action = $rule->{action};
		$action or next;
		push @actions, { index => $action->index(), data => $action->code() };
	}

	open my $fh, '>', $unitfile;
	printf $fh $header;
	printf $fh "unit %s;\n\n", $unitname;
	printf $fh "interface\n\n";
	printf $fh "uses System.SysUtils, System.Classes, WinApi.Windows, \n";
	printf $fh "     %s,\n", $_ foreach ( @{ $parser->{units} } );
	printf $fh "     Parse.Easy.Lexer.Token,\n";
	printf $fh "     %s,\n", $parentunitname if($parentunitname);
	printf $fh "     Parse.Easy.Parser.CustomParser;\n\n";
	printf $fh "type %s = class(%s)\n", $classname, $parentclassname;
	printf $fh "  protected\n";
	printf $fh "    procedure UserAction(Index: Integer); override;\n";
	printf $fh "  public\n";
	printf $fh "    class constructor Create;\n";
	printf $fh "end;\n\n";

	printf $fh "implementation\n\n";
	printf $fh "{\$R '%s'}\n\n", $resfile;

	printf $fh "{ %s }\n\n", $classname;

	printf $fh "class constructor %s.%s;\n", $classname, 'Create';
	printf $fh "begin\n";
	printf $fh "  Deserialize('%s');\n", uc $name;
	printf $fh "end;\n\n";

	printf $fh "procedure %s.%s(Index: Integer);\n", $classname, 'UserAction';
	printf $fh "begin\n";
	if (@actions) {
		printf $fh "  case Index of\n";
		foreach my $item (@actions) {
			printf $fh "  %04d:\n", $item->{index};
			printf $fh "    begin\n";
			printf $fh "      %s\n", $item->{data};
			printf $fh "    end;\n";
		}
		printf $fh "  end;\n";
	}
	printf $fh "end;\n\n";

	printf $fh "end.\n";
	close $fh;
}
1;
