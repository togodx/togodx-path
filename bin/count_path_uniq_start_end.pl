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

my @CSV = `ls *.csv`;
chomp(@CSV);

for my $csv (@CSV) {
    my ($dataset1, $dataset2);
    if ($csv =~ /^(\w+)-(\w+)\.csv$/) {
        ($dataset1, $dataset2) = ($1, $2);
    } else {
        die;
    }
    my $count1 = `cat $csv | cut -f1 -d, | sort | uniq | wc -l`;
    chomp($count1);
    my $count2 = `cat $csv | cut -f2 -d, | sort | uniq | wc -l`;
    chomp($count2);
    print "$dataset1\t$dataset2\t$count1\t$count2\n";
}
