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

my @path = `./js/togoid-route.js | sort -u`;
chomp(@path);
my %EDGE = ();
my %NODE = ();
for my $path (@path) {
    my @f = split("\t", $path);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    $NODE{$source} = 1;
    $NODE{$target} = 1;
    $EDGE{"${source}-${target}"} = 1;
}

my @togoid_config = `./js/list-togoid-config.js`;
chomp(@togoid_config);
for my $togoid_config (@togoid_config) {
    my @f = split("-", $togoid_config);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    if ($NODE{$source} && $NODE{$target} && $EDGE{$togoid_config}) {
        print "$source -> $target\n";
    }
}
