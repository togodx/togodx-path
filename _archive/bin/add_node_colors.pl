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
    print;
    if (/^  :Gene$/) {
        print '  color: "#3AA64C"', "\n";
    }
    if (/^  :Protein$/) {
        print '  color: "#79A63A"', "\n";
    }
    if (/^  :Structure$/) {
        print '  color: "#A6823A"', "\n";
    }
    if (/^  :Interaction$/) {
        print '  color: "#A63A43"', "\n";
    }
    if (/^  :Compound$/) {
        print '  color: "#A63A94"', "\n";
    }
    if (/^  :Glycan$/) {
        print '  color: "#673AA6"', "\n";
    }
    if (/^  :Disease$/) {
        print '  color: "#3A5EA6"', "\n";
    }
    if (/^  :Variant$/) {
        print '  color: "#3AA69D"', "\n";
    }
}
