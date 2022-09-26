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
my $NODE = "";
my $NODE_TYPE = "";
while (<>) {
    if (/^  color:/ && $NODE) {
    } else {
        print;
    }
    if (/^[a-z_]+/) {
        if (/^[a-z_]+$/) {
            $NODE = $_;
        } else {
            $NODE = "";
        }
    }
    if (/^  :([A-Z][a-z]+)$/) {
        $NODE_TYPE = $1;
    }
    if (/^  name:/) {
        if ($NODE_TYPE eq "Gene") {
            print '  color: "#3AA64C"', "\n";
        }
        if ($NODE_TYPE eq "Protein") {
            print '  color: "#79A63A"', "\n";
        }
        if ($NODE_TYPE eq "Structure") {
            print '  color: "#A6823A"', "\n";
        }
        if ($NODE_TYPE eq "Interaction") {
            print '  color: "#A63A43"', "\n";
        }
        if ($NODE_TYPE eq "Compound") {
            print '  color: "#A63A94"', "\n";
        }
        if ($NODE_TYPE eq "Glycan") {
            print '  color: "#673AA6"', "\n";
        }
        if ($NODE_TYPE eq "Disease") {
            print '  color: "#3A5EA6"', "\n";
        }
        if ($NODE_TYPE eq "Variant") {
            print '  color: "#3AA69D"', "\n";
        }        
    }
}
