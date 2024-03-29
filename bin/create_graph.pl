#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
use JSON;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM json/paths.json
-l: print dataset-links.tsv
-a: output attributes
-c DATASET_COUNT_FILE
";

my %OPT;
getopts('lac:', \%OPT);

if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($PATHS_JSON) = @ARGV;

STDOUT->autoflush;

my @TARGET_DATASET = ("ncbigene", "ensembl_gene",
                      "ensembl_transcript", # Added in v2022-11
                      "uniprot", "pdb", "chebi", "chembl_compound", "pubchem_compound", "glytoucan", "mondo", "mesh", "nando", "hp_phenotype", "togovar");

my %CATEGORY_COLOR = (
    "Gene" => "#3AA64C",
    "Transcript" => "#3AA64C",
    "Protein" => "#79A63A",
    "Structure" => "#A6823A",
    "Interaction" => "#A63A43",
    "Compound" => "#A63A94",
    "Glycan" => "#673AA6",
    "Phenotype" => "#3A5EA6",
    "Variant" => "#3AA69D",
    );

### External files ###
my $TOGOID_DATASET = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/dataset.tsv";
my $TOGOID_LINK = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/pair_link.tsv";
my $LINK_LABEL = "https://raw.githubusercontent.com/togoid/togoid-config/main/ontology/property.tsv";
####################

my %NODE = ();
my %EDGE = ();
get_nodes_and_edges($PATHS_JSON);

my @TOGOID_LINK = ();
my %LINK_LABEL = ();
get_togoid_link($TOGOID_LINK, $LINK_LABEL);

my %DATASET_CATEGORY = ();
my %DATASET_LABEL = ();
get_dataset_label($TOGOID_DATASET);

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
                       $LINK_LABEL{$source}{$target}
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
        my $dataset_label = $DATASET_LABEL{$node} || die;
        my $category = $DATASET_CATEGORY{$node} || die;
        my $color = $CATEGORY_COLOR{$category} || die;
        print "$node\n";
        print "  :$category\n";
        print "  display_label: \"$dataset_label\"\n";
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
            my $link_label = $LINK_LABEL{$source}{$target} || die;
            my $category = $DATASET_CATEGORY{$source} || die;
            my $color = $CATEGORY_COLOR{$category} || die;
            print "$source -> $target\n";
            print "  link: \"$source-$target\"\n";
            print "  display_label: \"$link_label\"\n";
            print "  color: \"$color\"\n";
            if ($OPT{a}) {
                print "  width: 5\n";
                print "  opacity: 0.7\n";
            }
        }
    }
}

if ($OPT{a}) {
    system "./bin/js/attributes-pg.js";
}

################################################################################
### Function ###################################################################
################################################################################
sub get_togoid_link {
    my ($togoid_link, $link_label) = @_;

    my %display_label = ();
    for my $line (`curl -LSsf $link_label`) {
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
        $LINK_LABEL{$source}{$target} = $display_label{$tio};
    }
}

sub get_dataset_label {
    my ($togoid_dataset) = @_;

    for my $line (`curl -LSsf $togoid_dataset`) {
        chomp($line);
        my @f = split("\t", $line);
        if (@f != 3) {
            die;
        }
        my $dataset = $f[0];
        my $label = $f[1];
        my $category = $f[2];
        $DATASET_LABEL{$dataset} = $label;
        $DATASET_CATEGORY{$dataset} = $category;
        ### Reaction => Interaction ###
        if ($category eq "Reaction") {
            $DATASET_CATEGORY{$dataset} = "Interaction";
        }
    }
}

sub get_nodes_and_edges {
    my ($json_file) = @_;

    open(JSON, "$json_file") || die "$!";
    my @line = <JSON>;
    close(JSON);
    my $json = join("", @line);

    my $r_hash = decode_json($json);
    for my $key (keys %{$r_hash}) {
        for my $target(keys %{${$r_hash}{$key}}) {
            my @path = @{${$r_hash}{$key}{$target}};
            for my $path (@path) {
                my @node = @{$path};
                for (my $i=0; $i<@node-1; $i++) {
                    my $source = $node[$i];
                    my $target = $node[$i+1];
                    $NODE{$source} = 1;
                    $NODE{$target} = 1;
                    $EDGE{$source}{$target} = 1;
                }
            }
        }
    }
}
