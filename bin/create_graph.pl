#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
use Cwd 'realpath';
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM json/paths.json
-l: print dataset-links.tsv
-c DATASET_COUNT_FILE
";

my %OPT;
getopts('lc:', \%OPT);

if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($PATHS_JSON) = @ARGV;

STDOUT->autoflush;

my @TARGET_DATASET = ("ncbigene", "ensembl_gene",
                      "ensembl_transcript", # Added in v2022-11
                      "uniprot", "pdb", "chebi", "chembl_compound", "pubchem_compound", "glytoucan", "mondo", "mesh", "nando", "hp", "togovar");

my %CATEGORY_COLOR = (
    "Gene" => "#3AA64C",
    "Transcript" => "#3AA64C",
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
my $TOGOID_LINK = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/pair_link.tsv";
my $TIO_LABEL = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/property.tsv";
my $CATEGORY_SHEET = `cat bin/etc/category_sheet`;
chomp($CATEGORY_SHEET);

my $EDGES_JS = "./bin/js/paths-to-edges.js";

my $DIR = dirname(realpath($0));
chdir "$DIR/.." or die "Cannot chdir to $DIR/..: $!";
if (-f $EDGES_JS) {
    if (!-d "bin/js/node_modules") {
        system "cd bin/js; npm install";
    }
} else {
    die "Not found: $EDGES_JS\n";
}
####################

my %NODE = ();
my %EDGE = ();
get_nodes_end_edges($EDGES_JS, $PATHS_JSON);

my %NODE_LABEL = ();
get_node_label($TOGOID_ONTOLOGY);

my @TOGOID_LINK = ();
my %EDGE_LABEL = ();
get_edge_label($TOGOID_LINK, $TIO_LABEL);

my %DATASET_CATEGORY = ();
get_dataset_category($CATEGORY_SHEET);

my %DATASET_COUNT = ();

if ($OPT{l}) {
    print "source\tsource category\ttarget\ttarget category\tdisplay_label (biological meaning)\n";
    for my $edge (@TOGOID_LINK) {
        my @f = split("-", $edge);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        if ($EDGE{$source}{$target}) {
            print join("\t",
                       $source,
                       $DATASET_CATEGORY{$source},
                       $target,
                       $DATASET_CATEGORY{$target},
                       $EDGE_LABEL{$source}{$target}
                ), "\n";
        }
    }
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

    ### Print nodes ###
    my %target_dataset = ();
    for my $dataset (@TARGET_DATASET) {
        $target_dataset{$dataset} = 1;
    }

    for my $node (sort keys %NODE) {
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
    for my $edge (@TOGOID_LINK) {
        my @f = split("-", $edge);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        if ($EDGE{$source}{$target}) {
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

################################################################################
### Function ###################################################################
################################################################################
sub get_edge_label {
    my ($togoid_link, $tio_label) = @_;

    my %display_label = ();
    for my $line (`curl -LSsf $tio_label`) {
        chomp($line);
        my @f = split("\t", $line);
        if (@f != 6) {
            die;
        }
        my $tio = $f[0];
        my $label = $f[2];
        $display_label{$tio} = $label;
    }

    for my $line (`curl -LSsf $togoid_link`) {
        chomp($line);
        my @f = split("\t", $line);
        if (@f != 4) {
            die;
        }
        my $source = $f[0];
        my $target = $f[1];
        my $tio = $f[2];
        push(@TOGOID_LINK, "${source}-${target}");
        $EDGE_LABEL{$source}{$target} = $display_label{$tio};
    }
}

sub get_dataset_category {
    my ($category_sheet) = @_;

    my @category = `curl -LSsf "$category_sheet"`;
    chomp(@category);

    for my $line (@category) {
        my @f = split("\t", $line);
        my $dataset = $f[0];
        my $category = $f[2];
        $DATASET_CATEGORY{$dataset} = $category;
        ### Reaction => Interaction ###
        if ($category eq "Reaction") {
            $DATASET_CATEGORY{$dataset} = "Interaction";
        }
        ### Phenotype => Disease ###
        if ($category eq "Phenotype") {
            $DATASET_CATEGORY{$dataset} = "Disease";
        }
    }
}

sub get_node_label {
    my ($togoid_ontology) = @_;

    my $dataset;
    for my $line (`curl -LSsf $togoid_ontology`) {
        chomp($line);
        if ($line =~ /^\S/) {
            $dataset = "";
        } elsif ($line =~ /^ +dcterms:identifier +"(.+)" +;/) {
            $dataset = $1;
        } elsif ($line =~ /^ +rdfs:label +"(.+)" +;/ && $dataset) {
            $NODE_LABEL{$dataset} = $1;
        }
    }
}

sub get_nodes_end_edges {
    my ($edges_js, $paths_json) = @_;

    for my $edge (`$edges_js $paths_json`) {
        chomp($edge);
        my @f = split("\t", $edge);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        $NODE{$source} = 1;
        $NODE{$target} = 1;
        $EDGE{$source}{$target} = 1;
    }
}
