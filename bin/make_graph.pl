#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
use Cwd 'realpath';
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM
-l: print dataset-links.tsv
-c DATASET_COUNT_FILE
";

my %OPT;
getopts('lc:', \%OPT);

STDOUT->autoflush;

my @TARGET_DATASET = ("ncbigene", "ensembl_gene", "uniprot", "pdb", "chebi", "chembl_compound", "pubchem_compound", "glytoucan", "mondo", "mesh", "nando", "hp", "togovar");

my %CATEGORY_COLOR = (
    "Gene" => "#3AA64C",
    "Protein" => "#79A63A",
    "Structure" => "#A6823A",
    "Interaction" => "#A63A43",
    "Compound" => "#A63A94",
    "Glycan" => "#673AA6",
    "Disease" => "#3A5EA6",
    "Variant" => "#3AA69D",
    );

### External files ###
my $TOGOID_ONTOLOGY = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/togoid-ontology.ttl";
my $EDGE_LABEL_SHEET = "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=1295950655";
my $CATEGORY_SHEET = "https://docs.google.com/spreadsheets/d/16I2HJCpDBeoencNmzfW576q73LIciTMZOCrD7PjtXS4/export?format=tsv&gid=927983300";

my $TOGOID_EDGES_JS = "./bin/js/togoid-edges.js";
my $TOGODX_ROUTE_JS = "./bin/js/togodx-route.js";

my $DIR = dirname(realpath($0));
chdir "$DIR/.." or die "Cannot chdir to $DIR/..: $!";
if (-f $TOGOID_EDGES_JS && -f $TOGODX_ROUTE_JS) {
    if (!-d "bin/js/node_modules") {
        system "cd bin/js; npm install";
    }
} else {
    die "Not found: $TOGOID_EDGES_JS $TOGODX_ROUTE_JS\n";
}

### Temporary files
my $TOGOID_ONTOLOGY_TMP = "tmp/togoid-ontology.ttl";
my $TOGOID_EDGES_TMP = "tmp/togoid-edges";
my $TOGODX_ROUTE_TMP = "tmp/togodx-route";
if (!-d "tmp") {
    mkdir("tmp") or die "$!";
}
####################

my @ALL_EDGE = get_all_togoid_edges($TOGOID_EDGES_JS, $TOGOID_EDGES_TMP);

my %TOGODX_NODE = ();
my %TOGODX_ROUTE = ();
get_togodx_route_and_node($TOGODX_ROUTE_JS, $TOGODX_ROUTE_TMP);

my %NODE_LABEL = ();
get_node_label($TOGOID_ONTOLOGY, $TOGOID_ONTOLOGY_TMP);

my %EDGE_LABEL = ();
get_edge_label($EDGE_LABEL_SHEET);

my %DATASET_CATEGORY = ();
get_dataset_category($CATEGORY_SHEET);

my %DATASET_COUNT = ();

if ($OPT{l}) {
    print_dataset_links();
} else {
    if ($OPT{c}) {
        open(DATASET_COUNT, $OPT{c}) || die;
        while (<DATASET_COUNT>) {
            chomp;
            my ($dataset, $count);
            if (/^(\w+)\t(\d+)/) {
                ($dataset, $count) = ($1, $2);
                $DATASET_COUNT{$dataset} = $count;
            }
        }
        close(DATASET_COUNT) || die;
    }
    print_pg();
}

################################################################################
### Function ###################################################################
################################################################################
sub print_dataset_links {

    print "source\tsource category\ttarget\ttarget category\tdisplay_label (biological meaning)\n";
    for my $edge (@ALL_EDGE) {
        my @f = split("-", $edge);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        if ($TOGODX_ROUTE{$source}{$target}) {
            print join("\t",
                       $source,
                       $DATASET_CATEGORY{$source},
                       $target,
                       $DATASET_CATEGORY{$target},
                       $EDGE_LABEL{$source}{$target}
                ), "\n";
        }
    }
}

sub print_pg {

    ### Print nodes ###
    my %target_dataset = ();
    for my $dataset (@TARGET_DATASET) {
        $target_dataset{$dataset} = 1;
    }

    for my $node (sort keys %TOGODX_NODE) {
        my $node_label = $NODE_LABEL{$node} || die;
        my $category = $DATASET_CATEGORY{$node} || die;
        my $color = $CATEGORY_COLOR{$category} || die;
        print "$node\n";
        print "  :$category\n";
        print "  display_label: \"$node_label\"\n";
        print "  color: \"$color\"\n";
        if ($DATASET_COUNT{$node}) {
            my $count = $DATASET_COUNT{$node};
            # my $log_size = sprintf("%.2f", log($count)*3);
            print "  count: $count\n";
        }
        if (!$target_dataset{$node}) {
            print "  size: 10\n";
        }
    }

    ### Print edges ###
    for my $edge (@ALL_EDGE) {
        my @f = split("-", $edge);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        if ($TOGODX_ROUTE{$source}{$target}) {
            my $edge_label = $EDGE_LABEL{$source}{$target} || die;
            my $category = $DATASET_CATEGORY{$source} || die;
            my $color = $CATEGORY_COLOR{$category} || die;
            print "$source -> $target\n";
            print "  link: \"$source-$target\"\n";
            print "  display_label: \"$edge_label\"\n";
            print "  color: \"$color\"\n";
        }
    }
}

sub get_all_togoid_edges {
    my ($togoid_edges_js, $togoid_edges_tmp) = @_;

    if (!-f $togoid_edges_tmp) {
        if (-f $togoid_edges_js) {
            system "$togoid_edges_js > $togoid_edges_tmp";
        } else {
            die;
        }
    }
    open(LIST, $togoid_edges_tmp) || die "$!";
    my @edge = <LIST>;
    chomp(@edge);
    close(LIST);

    return @edge
}

sub get_edge_label {
    my ($edge_label_sheet) = @_;

    my @table = `curl -LSsf "$edge_label_sheet"`;
    chomp(@table);

    for my $line (@table) {
        my @f = split("\t", $line);
        my $source = $f[6];
        my $target = $f[8];
        my $edge_label = $f[29];
        $EDGE_LABEL{$source}{$target} = $edge_label;
    }
}

sub get_dataset_category {
    my ($category_sheet) = @_;

    my @category = `curl -LSsf "$category_sheet"`;
    chomp(@category);

    for my $line (@category) {
        my @f = split("\t", $line);
        my $dataset = $f[0];
        my $category = $f[1];
        $DATASET_CATEGORY{$dataset} = $category;
        ### Reaction => Interaction ###
        if ($category eq "Reaction") {
            $DATASET_CATEGORY{$dataset} = "Interaction";
        }
    }
}

sub get_node_label {
    my ($togoid_ontology, $togoid_ontology_tmp) = @_;

    if (!-s $togoid_ontology_tmp) {
        system "curl -LSsf $togoid_ontology > $togoid_ontology_tmp";
    }
    open(ONTOLOGY, $togoid_ontology_tmp) || die "$!";
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

sub get_togodx_route_and_node {
    my ($togodx_route_js, $togodx_route_tmp) = @_;

    if (!-f $togodx_route_tmp) {
        if (-f $togodx_route_js) {
            system "$togodx_route_js | sort -u > $togodx_route_tmp";
        } else {
            die;
        }
    }
    open(ROUTE, "$togodx_route_tmp") || die "$!";
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
