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

my $TOGOID_ROUTE_JS = "./bin/js/togoid-route.js";
my $TOGOID_CONFIG_JS = "./bin/js/list-togoid-config.js";

if (!-d "tmp") {
    mkdir("tmp") or die "$!";
}
my $TOGOID_ONTOLOGY_TMP = "tmp/togoid-ontology.ttl";
my $TOGOID_CONFIG_TMP = "tmp/togoid-config";
my $TOGOID_ROUTE_TMP = "tmp/togoid-route";

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

my @EDGE = get_all_togoid_edges();

my %EDGE_LABEL = ();
get_edge_label();

my %NODE_LABEL = ();
get_node_label();

my %CATEGORY = ();
get_category();

my %TOGODX_NODE = ();
my %TOGODX_ROUTE = ();
get_togodx_node_and_route();

### Print nodes
for my $node (sort keys %TOGODX_NODE) {
    my $node_label = $NODE_LABEL{$node} || die;
    my $category = $CATEGORY{$node} || die;
    my $color = $COLOR{$category} || die;
    print "$node\n";
    print "  :$category\n";
    print "  display_label: \"$node_label\"\n";
    print "  color: \"$color\"\n";
    if (!$TARGET{$node}) {
        print "  size: 10\n";
    }
}

### Print edges
for my $edge (@EDGE) {
    my @f = split("-", $edge);
    if (@f != 2) {
        die;
    }
    my ($source, $target) = @f;
    if ($TOGODX_ROUTE{$source}{$target}) {
        my $edge_label = $EDGE_LABEL{$source}{$target} || die;
        my $category = $CATEGORY{$source} || die;
        my $color = $COLOR{$category} || die;
        print "$source -> $target\n";
        print "  link: \"$source-$target\"\n";
        print "  display_label: \"$edge_label\"\n";
        print "  color: \"$color\"\n";
    }
}

################################################################################
### Function ###################################################################
################################################################################
sub get_all_togoid_edges {

    if (!-f $TOGOID_CONFIG_TMP) {
        if (-f $TOGOID_CONFIG_JS) {
            system "$TOGOID_CONFIG_JS > $TOGOID_CONFIG_TMP";
        } else {
            die;
        }
    }
    open(LIST, $TOGOID_CONFIG_TMP) || die "$!";
    my @edge = <LIST>;
    chomp(@edge);
    close(LIST);

    return @edge
}

sub get_edge_label {

    my @table = `curl -LSsf "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=1295950655"`;
    chomp(@table);

    for my $line (@table) {
        my @f = split("\t", $line);
        my $source = $f[6];
        my $target = $f[8];
        my $edge_label = $f[29];
        $EDGE_LABEL{$source}{$target} = $edge_label;
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
        ### to be checked ###
        if ($category eq "Reaction") {
            $CATEGORY{$dataset} = "Interaction";
        }
    }
}

sub get_node_label {

    if (!-s $TOGOID_ONTOLOGY_TMP) {
        system "curl -LSsf https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/togoid-ontology.ttl > $TOGOID_ONTOLOGY_TMP";
    }
    open(ONTOLOGY, $TOGOID_ONTOLOGY_TMP) || die "$!";
    my @ontology = <ONTOLOGY>;
    chomp(@ontology);

    my $dataset;
    for my $line (@ontology) {
        if ($line =~ /^\S/) {
            $dataset = "";
        } elsif ($line =~ /^ +dcterms:identifier +"(.+)" +;/) {
            $dataset = $1;
        } elsif ($line =~ /^ +rdfs:label +"(.+)" +;/ && $dataset) {
            $NODE_LABEL{$dataset} = $1;
        }
    }
    close(ONTOLOGY);
}

sub get_togodx_node_and_route {

    if (!-f $TOGOID_ROUTE_TMP) {
        if (-f $TOGOID_ROUTE_JS) {
            system "$TOGOID_ROUTE_JS | sort -u > $TOGOID_ROUTE_TMP";
        } else {
            die;
        }
    }
    open(ROUTE, "$TOGOID_ROUTE_TMP") || die "$!";
    my @route = <ROUTE>;
    chomp(@route);
    close(ROUTE);

    for my $route (@route) {
        my @f = split("\t", $route);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        $TOGODX_NODE{$source} = 1;
        $TOGODX_NODE{$target} = 1;
        $TOGODX_ROUTE{$source}{$target} = 1;
    }
}
