#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM
";

my %OPT;
getopts('', \%OPT);

!@ARGV && -t and die $USAGE;
while (<>) {
    chomp;
    if (/^  width: (\S+)$/) {
        my $width = $1 * 1.5;
        print "  width: $width\n";
    } else {
        print "$_\n";
    }
}
