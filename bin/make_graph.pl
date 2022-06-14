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

my $TOGOID_ONTOLOGY_TMP = "node_label.tmp";
my $TOGOID_CONFIG_TMP = "js/list-togoid-config.tmp";
my $TOGOID_ROUTE_TMP = "js/togoid-route.tmp";
my $TOGOID_ROUTE_JS = ".js/togoid-route.js";
my $TOGOID_CONFIG_JS = "js/list-togoid-config.js";

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
get_display_label();
my %CATEGORY = ();
get_category();
my %CLASS_LABEL = ();
get_class_label();

my %NODE = ();
my %ROUTE = ();
get_route_and_node();

### Print nodes
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

### Print edges
if (!-f $TOGOID_CONFIG_TMP) {
    if (-f $TOGOID_CONFIG_JS) {
        system "$TOGOID_CONFIG_JS > $TOGOID_CONFIG_TMP";
    } else {
        die;
    }
}
open(LIST, $TOGOID_CONFIG_TMP) || die "$!";
my @EDGE = <LIST>;
chomp(@EDGE);
close(LIST);

for my $edge (@EDGE) {
    my @f = split("-", $edge);
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

################################################################################
### Function ###################################################################
################################################################################
sub get_display_label {

    my @table = `curl -LSsf "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=1295950655"`;
    chomp(@table);

    for my $line (@table) {
        my @f = split("\t", $line);
        my $source = $f[6];
        my $target = $f[8];
        my $display_label = $f[29];
        $DISPLAY_LABEL{$source}{$target} = $display_label;
    }
}

sub get_category {

    my @category = `curl -LSsf "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=927983300"`;
    chomp(@category);

    for my $line (@category) {
        my @f = split("\t", $line);
        my $dataset = $f[0];
        my $category = $f[1];
        $CATEGORY{$dataset} = $category;
        if ($category eq "Reaction") {
            $CATEGORY{$dataset} = "Interaction";
        }
    }
}

sub get_class_label {

    if (!-s $TOGOID_ONTOLOGY_TMP) {
        system "curl -LSsf https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/togoid-ontology.ttl > $TOGOID_ONTOLOGY_TMP";
    }
    open(ONTOLOGY, $TOGOID_ONTOLOGY_TMP) || die "$!";
    my @ontology = <ONTOLOGY>;
    chomp(@ontology);

    my $class_id;
    for my $line (@ontology) {
        if ($line =~ /^\S/) {
            $class_id = "";
        } elsif ($line =~ /^ +dcterms:identifier +"(.+)" +;/) {
            $class_id = $1;
        } elsif ($line =~ /^ +rdfs:label +"(.+)" +;/ && $class_id) {
            $CLASS_LABEL{$class_id} = $1;
        }
    }
    close(ONTOLOGY);
}

sub get_route_and_node {

    if (!-f $TOGOID_ROUTE_TMP) {
        if (-f $TOGOID_ROUTE_JS) {
            system "$TOGOID_ROUTE_JS | sort -u > $TOGOID_ROUTE_TMP";
        } else {
            die;
        }
    }
    open(ROUTE, "$TOGOID_ROUTE_TMP") || die "$!";
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
}
