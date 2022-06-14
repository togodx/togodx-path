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

my %TARGET = (
    'ncbigene' => 1, 
    'ensembl_gene' => 1,
    'uniprot' => 1,
    'pdb' => 1,
    'chebi' => 1,
    'chembl_compound' => 1,
    'pubchem_compound' => 1,
    'glytoucan' => 1, 
    'mondo' => 1,
    'mesh' => 1,
    'nando' => 1,
    'hp' => 1,
    'togovar' => 1
    );

my %COLOR = (
    "Gene" => "#3AA64C",
    "Protein" => "#79A63A",
    "Structure" => "#A6823A",
    "Interaction" => "#A63A43",
    "Compound" => "#A63A94",
    "Glycan" => "#673AA6",
    "Disease" => "#3A5EA6",
    "Variant" => "#3AA69D",
    );

my %DISPLAY_LABEL = ();
my @TABLE = `curl -LSsf "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=1295950655"`;
chomp(@TABLE);
for my $line (@TABLE) {
    my @f = split("\t", $line);
    my $source = $f[6];
    my $target = $f[8];
    my $display_label = $f[29];
    $DISPLAY_LABEL{$source}{$target} = $display_label;
}

my %CATEGORY = ();
my @CATEGORY = `curl -LSsf "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=927983300"`;
chomp(@CATEGORY);
for my $line (@CATEGORY) {
    my @f = split("\t", $line);
    my $dataset = $f[0];
    my $category = $f[1];
    $CATEGORY{$dataset} = $category;
    if ($category eq "Reaction") {
        $CATEGORY{$dataset} = "Interaction";
    }
}

if (!-s "node_label.tmp") {
    system "curl -LSsf https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/togoid-ontology.ttl > node_label.tmp";
}
open(ONTOLOGY, "node_label.tmp") || die "$!";
my @ONTOLOGY = <ONTOLOGY>;
chomp(@ONTOLOGY);
my %CLASS_LABEL = ();
my $CLASS;
for my $line (@ONTOLOGY) {
    if ($line =~ /^\S/) {
        $CLASS = "";
    } elsif ($line =~ /^ +dcterms:identifier +"(.+)" +;/) {
        $CLASS = $1;
    } elsif ($line =~ /^ +rdfs:label +"(.+)" +;/ && $CLASS) {
        $CLASS_LABEL{$CLASS} = $1;
    }
}
close(ONTOLOGY);

my %NODE = ();
my %ROUTE = ();
if (!-f "js/togoid-route.tmp") {
    if (-f "js/togoid-route.js") {
        system "./js/togoid-route.js | sort -u > js/togoid-route.tmp";
    } else {
        die;
    }
}
open(ROUTE, "js/togoid-route.tmp") || die "$!";
my @ROUTE = <ROUTE>;
chomp(@ROUTE);
close(ROUTE);
for my $route (@ROUTE) {
    my @f = split("\t", $route);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    $NODE{$source} = 1;
    $NODE{$target} = 1;
    $ROUTE{$source}{$target} = 1;
}

for my $node (sort keys %NODE) {
    my $category = $CATEGORY{$node} || die;
    print "$node\n";
    print "  :$category\n";
    print "  display_label: \"$CLASS_LABEL{$node}\"\n";
    print "  color: \"$COLOR{$category}\"\n";
    if (!$TARGET{$node}) {
        print "  size: 10\n";
    }
}

if (!-f "js/list-togoid-config.tmp") {
    if (-f "js/list-togoid-config.js") {
        system "./js/list-togoid-config.js > js/list-togoid-config.tmp";
    } else {
        die;
    }
}
open(LIST, "js/list-togoid-config.tmp") || die "$!";
my @EDGE = <LIST>;
chomp(@EDGE);
close(LIST);
for my $EDGE (@EDGE) {
    my @f = split("-", $EDGE);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    if ($ROUTE{$source}{$target}) {
        my $category = $CATEGORY{$source} || die;
        print "$source -> $target\n";
        print "  link: \"$source-$target\"\n";
        print "  display_label: \"$DISPLAY_LABEL{$source}{$target}\"\n";
        print "  color: \"$COLOR{$category}\"\n";
    }
}
