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
    print $_, "\n";
    if (/^([a-z_]+) -> ([a-z_]+)$/) {
        print "  name: \"$1-$2\"\n";
    }
}
