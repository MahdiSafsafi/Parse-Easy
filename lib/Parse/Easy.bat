@echo off

set "current_dir=%~dp0"
for %%I in ("%current_dir%\..") do set "lib_folder=%%~fI"

rem run perl.

perl -I %lib_folder% -x -S  %0  %*

goto END_OF_PERL

rem Perl script:
#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);
use Parse::Easy;

my ($file) = @ARGV;

my $easy = Parse::Easy->new($file);
$easy->generate();

__END__

:END_OF_PERL

