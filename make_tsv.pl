#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [PG_FILE]
";

my %OPT;
getopts('', \%OPT);

STDOUT->autoflush;
my $source;
my $target;
my $node;
my %CATEGORY = ();
print "source\tsource_category\ttarget\ttarget_category\tdisplay_label\n";
while (<>) {
    chomp;
    if (/^([_a-z]+)$/) {
        $node = $1;
    }
    if ($node && /^  :(\S+)$/) {
        my $category = $1;
        $CATEGORY{$node} = $category;
    }
    if (/^(\S+) *-> *(\S+)$/) {
        $source = $1;
        $target = $2;
    }
    if ($source && $target && /display_label: *"(.+)"/) {
        my $display_label = $1;
        print "$source\t$CATEGORY{$source}\t$target\t$CATEGORY{$target}\t$display_label\n";
    }
}
