#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Target/Pascal/Lexer.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Target::Pascal::Lexer;
use strict;
use warnings;
use Parse::Easy::Target::Pascal::Header qw(get_header);
my $header = get_header();

sub new {
	my ( $class, $lexer ) = @_;
	my $self = { lexer => $lexer, };
	bless $self, $class;
	$self;
}

sub generate {
	my ($self)    = @_;
	my $lexer     = $self->{lexer};
	my $name      = $lexer->{name};
	my $unitname  = $name;
	my $classname = "T" . $name;
	my $file      = "$name.pas";
	my @actions   = ();
	my @tokens    = ();
	foreach my $rule ( @{ $lexer->{rules} } ) {
		my $action = $rule->{action};
		$action or next;
		push @actions, { index => $action->index(), data => $action->code() };
	}
	foreach my $key ( sort keys %{ $lexer->{tokens} } ) {
		my $value = $lexer->{tokens}->{$key};
		push @tokens, { index => $value, data => $key };
	}
	@tokens = sort { $a->{index} - $b->{index} } @tokens;
	open my $fh, '>', $file or die "unable to create file '$file'";
	printf $fh $header;
	printf $fh "unit %s;\n\n", $unitname;
	printf $fh "interface\n\n";
	printf $fh "uses System.SysUtils, WinApi.Windows,\n";
	printf $fh "     Parse.Easy.Lexer.CustomLexer;\n\n";
	
	printf $fh "type %s = class(TCustomLexer)\n", $classname;
	printf $fh "  protected\n";
	printf $fh "    procedure UserAction(Index: Integer); override;\n";
	printf $fh "  public\n";
	printf $fh "    class constructor Create;\n";
	printf $fh "    function  GetTokenName(Index: Integer): string; override;\n";
	printf $fh "end;\n\n";

	printf $fh "const\n\n";
	printf $fh "  %-10s = %04d;\n", $_->{data}, $_->{index} foreach (@tokens);
	printf $fh "  %-10s = %04d;\n", $_->{name}, $_->{index} foreach ( @{ $lexer->{sections} } );

	printf $fh "\n\n";

	printf $fh "implementation\n\n";
	printf $fh "{\$R %s.RES}\n\n", $name;

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

	printf $fh "function %s.%s(Index: Integer): string;\n", $classname, 'GetTokenName';
	printf $fh "begin\n";
	if (@tokens) {
		printf $fh "  case Index of\n";
		printf $fh "    %04d : exit(%-10s);\n", $_->{index}, "'$_->{data}'" foreach (@tokens);
		printf $fh "  end;\n";
	}
	printf $fh "  Result := 'Unkown' + IntToStr(Index);\n";
	printf $fh "end;\n\n";

	printf $fh "end.\n";
	close $fh;
}
1;
