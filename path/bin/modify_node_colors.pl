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
            print '  color: "#78da88"', "\n";
        }
        if ($NODE_TYPE eq "Protein") {
            print '  color: "#b1da78"', "\n";
        }
        if ($NODE_TYPE eq "Structure") {
            print '  color: "#dab978"', "\n";
        }
        if ($NODE_TYPE eq "Interaction") {
            print '  color: "#da7880"', "\n";
        }
        if ($NODE_TYPE eq "Compound") {
            print '  color: "#da78c9"', "\n";
        }
        if ($NODE_TYPE eq "Glycan") {
            print '  color: "#a078da"', "\n";
        }
        if ($NODE_TYPE eq "Disease") {
            print '  color: "#7898da"', "\n";
        }
        if ($NODE_TYPE eq "Variant") {
            print '  color: "#78dad1"', "\n";
        }        
    }
}
