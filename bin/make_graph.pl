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

my $DATASET_LINKS_ALL_JS = "./bin/js/dataset-links-all.js";
my $PATHS_JS = "./bin/js/paths.js";

my $DIR = dirname(realpath($0));
chdir "$DIR/.." or die "Cannot chdir to $DIR/..: $!";
if (-f $DATASET_LINKS_ALL_JS && -f $PATHS_JS) {
    if (!-d "bin/js/node_modules") {
        system "cd bin/js; npm install";
    }
} else {
    die "Not found: $DATASET_LINKS_ALL_JS $PATHS_JS\n";
}

### Temporary files
my $TOGOID_ONTOLOGY_TMP = "tmp/togoid-ontology.ttl";
my $DATASET_LINKS_ALL_TMP = "tmp/dataset-links-all";
my $PATHS_TMP = "tmp/paths.tsv";
if (!-d "tmp") {
    mkdir("tmp") or die "$!";
}
####################

my @ALL_EDGE = dataset_links_all();

my %NODE = ();
my %EDGE = ();
get_nodes_end_edges($PATHS_JS, $PATHS_TMP);

my %NODE_LABEL = ();
get_node_label($TOGOID_ONTOLOGY, $TOGOID_ONTOLOGY_TMP);

my %EDGE_LABEL = ();
get_edge_label($EDGE_LABEL_SHEET);

my %DATASET_CATEGORY = ();
get_dataset_category($CATEGORY_SHEET);

my %DATASET_COUNT = ();

if ($OPT{l}) {
    print "source\tsource category\ttarget\ttarget category\tdisplay_label (biological meaning)\n";
    for my $edge (@ALL_EDGE) {
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
    for my $edge (@ALL_EDGE) {
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
sub dataset_links_all {

    if (!-f $DATASET_LINKS_ALL_TMP) {
        if (-f $DATASET_LINKS_ALL_JS) {
            system "$DATASET_LINKS_ALL_JS > $DATASET_LINKS_ALL_TMP";
        } else {
            die;
        }
    }
    open(LIST, $DATASET_LINKS_ALL_TMP) || die "$!";
    my @list = <LIST>;
    chomp(@list);
    close(LIST);

    return @list;
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

sub get_nodes_end_edges {
    my ($paths_js, $paths_tmp) = @_;

    if (!-f $paths_tmp) {
        if (-f $paths_js) {
            system "$paths_js --tsv | sort -u > $paths_tmp";
        } else {
            die;
        }
    }
    open(PATHS, "$paths_tmp") || die "$!";
    my @link = <PATHS>;
    chomp(@link);
    close(PATHS);

    for my $link (@link) {
        my @f = split("\t", $link);
        if (@f != 2) {
            die;
        }
        my ($source, $target) = @f;
        $NODE{$source} = 1;
        $NODE{$target} = 1;
        $EDGE{$source}{$target} = 1;
    }
}
