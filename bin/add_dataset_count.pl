#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: cat GRAPH.pg | $PROGRAM dataset_count_ids.json
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
    my ($dataset, $count);
    if (/"(\w+)": "(\d+)"/) {
        ($dataset, $count) = ($1, $2);
        $NODE_SIZE{$dataset} = $count;
    }
}
close(SIZE_FILE) || die;;

-t and die $USAGE;
my $NODE = "";
while (<STDIN>) {
    chomp;
    if (/^[a-z_]+/) {
        if ($NODE_SIZE{$NODE}) {
            my $n = $NODE_SIZE{$NODE};
            my $log_size = sprintf("%.2f", log($n)*3);
            # print "  size: ", $log_size, "\n";
            print "  count: $n\n";
        }
        if (/^([a-z_]+)$/) {
            $NODE = $_;
        } else {
            $NODE = "";
        }
    }
    print "$_\n";
}
