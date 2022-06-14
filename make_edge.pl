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

my %ROUTE = ();
my @ROUTE = `./js/togoid-route.js | sort -u`;
chomp(@ROUTE);
for my $route (@ROUTE) {
    my @f = split("\t", $route);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    $ROUTE{$source}{$target} = 1;
}

my @EDGE = `./js/list-togoid-config.js`;
chomp(@EDGE);
for my $EDGE (@EDGE) {
    my @f = split("-", $EDGE);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    if ($ROUTE{$source}{$target}) {
        print "$source -> $target\n";
    }
}
