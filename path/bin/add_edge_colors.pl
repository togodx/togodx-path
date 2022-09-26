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
my %COLOR;
my $NODE = "";
my $START = "";
while (<>) {
    chomp;
    print $_, "\n";
    if (/^[a-z_]+$/) {
        $NODE = $_;
    }
    if (/^  color: /) {
        $COLOR{$NODE} = $_;
    }
    if (/^([a-z_]+) -> [a-z_]+$/) {
        $START = $1;
    }
    if (/^  width:/) {
        if ($COLOR{$START}) {
            print $COLOR{$START}, "\n";
        } else {
            die;
        }
    }
}
