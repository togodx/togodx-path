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
my ($ID_LIST) = @ARGV;

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

# my @CSV = ("chebi-mesh.csv");
my @CSV = `ls *.csv`;
chomp(@CSV);
my %NOT_FOUND = ();
for my $csv (@CSV) {
    my ($dataset1, $dataset2);
    if ($csv =~ /^(\w+)-(\w+)\.csv$/) {
        ($dataset1, $dataset2) = ($1, $2);
    } else {
        die;
    }
    open(CSV, $csv) || die;
    while (<CSV>) {        
        chomp;
        my @f = split(",", $_);
        if (@f != 2) {
            die;
        }
        my ($id1, $id2) = @f;
        if (!$ID_LIST{$dataset1}{$id1}) {
            $NOT_FOUND{$dataset1}{$id1} = 1;
        }
        if (!$ID_LIST{$dataset2}{$id2}) {
            $NOT_FOUND{$dataset2}{$id2} = 1;
        }
    }
    close(CSV);
}

for my $dataset (keys %NOT_FOUND) {
    my $n = keys %{$NOT_FOUND{$dataset}};
    print "$dataset\t$n\n";
    # for my $id (keys %{$NOT_FOUND{$dataset}}) {
    #     print "$dataset $id\n";
    # }
}
