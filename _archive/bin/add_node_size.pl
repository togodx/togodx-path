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

if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($SIZE_FILE) = @ARGV;

my %NODE_SIZE;
open(SIZE_FILE, $SIZE_FILE) || die;
while (<SIZE_FILE>) {
    chomp;
    my @f = split;
    if (@f != 2) {
        die;
    }
    $NODE_SIZE{$f[0]} = $f[1];
}
close(SIZE_FILE) || die;;

-t and die $USAGE;
my $NODE = "";
while (<STDIN>) {
    chomp;
    print "$_\n";
    if (/^[a-z_]+/) {
        if (/^([a-z_]+)$/) {
            $NODE = $_;
        } else {
            $NODE = "";
        }
    }
    if (/^  name:/) {
        my $n = $NODE_SIZE{$NODE};
        my $log_size = sprintf("%.2f", log($n)/log(10)) * 3;
        print "  N: $n\n";
        print "  size: ", $log_size, "\n";
    }    
}
