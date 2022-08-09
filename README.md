# TogoDX path

ID links between datasets
* https://togodx.github.io/togodx-path/path-selected.html

Highlighting ID conversion path
* https://togodx.github.io/togodx-path/path-highlight.html

Reproducing the graph of ID links
```
$ ./bin/make_graph.pl > graph/path-selected.pg

$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```
```
$ ./bin/make_tsv.pl graph/path-selected.pg > tsv/path-selected.tsv
```

Reproducing the path used in TogoDX/Human
```
$ ./bin/js/togodx-path.js > json/path.json
```

Count IDs
```
$ ./bin/js/togodx-attributes-count.js data/json/ > tsv/attribute-count.tsv
$ ./bin/js/togodx-attributes-count.js data/json/ -d > tsv/dataset-count.tsv
$ ./bin/js/togodx-attributes-count.js data/json/ -d -j > json/dataset-count.json
$ (cd data/relation/output; wc -l *.csv) | grep -v total | perl -pe 's/^\s*(\d+)\s(\S+)\.csv$/$2\t$1/' > tsv/path-count.tsv
$ ./bin/js/path-count-tsv2json.js tsv/path-count.tsv > json/path-count.json
$ ./bin/count_path_uniq_start_end.pl data/relation/output/ > tsv/path-count-uniq-start-end.tsv
$ ./bin/js/path-count-start-end-tsv2json.js tsv/path-count-uniq-start-end.tsv > json/path-count-uniq-start-end.json
```
