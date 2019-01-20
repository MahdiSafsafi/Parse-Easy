#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use autodie;
use feature qw/say/;

my @files  = ();
my $shebang = '#!/usr/bin/perl';
my $HEADER = <<'EOH';

#BEGIN_HEADER
#
# Module $name Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

EOH

sub wanted {
	local $_ = $File::Find::name;
	/\.(p[ml])$/ and push @files, $_;
}

find( \&wanted, '..\lib' );

foreach my $file (@files) {
	$file =~ /.lib.(.+)/;
	my $name = $1;
	$name =~ /Parse.Easy.Parse.Parser/ and next;
	
	local $/ = undef;
	open my $fh, '<', $file;
	local $_ = <$fh>;
	close $fh;
	
	s/\Q$shebang\E\n+//s;
	s/#BEGIN_HEADER.+?#END_HEADER\n+//s;
	
	my $header = $HEADER;
	$header =~ s/\$name/$name/;
	$_ = $shebang . "\n" . $header . $_;
	
	open $fh, '>', $file;
	print $fh $_;
	close $fh;
}
1;