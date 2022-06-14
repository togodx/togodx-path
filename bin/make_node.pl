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

my %NODE = ();
my @ROUTE = `./js/togoid-route.js | sort -u`;
chomp(@ROUTE);
for my $route (@ROUTE) {
    my @f = split("\t", $route);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    $NODE{$source} = 1;
    $NODE{$target} = 1;
}

for my $node (sort keys %NODE) {
    print "$node\n";
}
