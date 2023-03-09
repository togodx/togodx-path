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
    if (/^\s+N:\s*(\d+)$/) {
        my $n = $1;
        my $logN = sprintf "%.2f", log($n)/log(10);
        print "  width: $logN\n";
    }
}
