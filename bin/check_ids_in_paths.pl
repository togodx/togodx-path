#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM data/relation/output/
";

my %OPT;
getopts('', \%OPT);

if (@ARGV != 1) {
    print STDERR $USAGE;
    exit 1;
}
my ($DIR) = @ARGV;

my $DATASET_COUNT_FILE = "tsv/dataset-count-ids.tsv";
my $ID_LIST = "tsv/ids.tsv";

STDOUT->autoflush;

# my %DATASET_COUNT = ();
# open(DATASET_COUNT, "$DATASET_COUNT_FILE") || die;
# while (<DATASET_COUNT>) {
#     chomp;
#     my @f = split;
#     if (@f != 2) {
#         die;
#     }
#     my ($dataset, $count) = @f;
#     if ($count =~ /^\d+$/) {
#         $DATASET_COUNT{$dataset} = $count;
#     }
# }
# close(DATASET_COUNT);

my %ID_LIST = ();
open(ID_LIST, "$ID_LIST") || die;
while (<ID_LIST>) {
    chomp;
    my @f = split;
    if (@f != 2) {
        die;
    }
    my ($dataset, $id) = @f;
    $ID_LIST{$dataset}{$id} = 1;
}
close(ID_LIST);

chdir($DIR) || die "$DIR: $!";

my @CSV = `ls *.csv`;
chomp(@CSV);
for my $csv (@CSV) {
    my ($dataset1, $dataset2);
    if ($csv =~ /^(\w+)-(\w+)\.csv$/) {
        ($dataset1, $dataset2) = ($1, $2);
    } else {
        die;
    }

    my %found = ();
    my %combinations = ();
    open(CSV, $csv) || die;
    while (<CSV>) {        
        chomp;
        my @f = split(",", $_);
        if (@f != 2) {
            die;
        }
        my ($id1, $id2) = @f;
        if ($ID_LIST{$dataset1}{$id1} && $ID_LIST{$dataset2}{$id2}) {
            $found{$dataset1}{$id1} = 1;
            $found{$dataset2}{$id2} = 1;
            $combinations{"$id1\t$id2"} = 1;
        }
    }
    close(CSV);

    print $dataset1;
    print "\t";
    print $dataset2;
    print "\t", scalar(keys(%{$found{$dataset1}}));
    # print "/", $DATASET_COUNT{$dataset1};
    print "\t", scalar(keys(%{$found{$dataset2}}));
    # print "/", $DATASET_COUNT{$dataset2};
    print "\t", scalar(keys(%combinations));
    print "\n";
}
