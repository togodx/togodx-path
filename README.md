# TogoDX path

ID links between datasets
* https://togodx.github.io/togodx-path/path-selected.html

Highlighting ID conversion path
* https://togodx.github.io/togodx-path/path-highlight.html

Checking ID counts
* https://togodx.github.io/togodx-path/path-count.html

Display attributes
* https://togodx.github.io/togodx-path/path-attr.html

Reproducing the graph of ID links
```
$ ./bin/make_graph.pl > graph/path.pg

$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```
```
$ ./bin/make_tsv.pl graph/path.pg > tsv/dataset-links.tsv
```

Reproducing the path used in TogoDX/Human
```
$ ./bin/js/togodx-path.js > json/paths.json
```

Count IDs
```
$ ./bin/js/togodx-attributes-count.js data/json/ > tsv/attribute-count-ids.tsv
$ ./bin/js/togodx-attributes-count.js data/json/ -d > tsv/dataset-count.tsv
$ ./bin/js/togodx-attributes-count.js data/json/ -d -j > json/dataset-count.json
$ ./bin/js/togodx-attributes-count.js data/json/ -l > tsv/ids.tsv
$ (cd data/relation/output; wc -l *.csv) | grep -v total | perl -pe 's/^\s*(\d+)\s(\S+)\.csv$/$2\t$1/' > tsv/paths-count.tsv
$ ./bin/js/paths-count-tsv2json.js tsv/paths-count.tsv > json/paths-count.json
$ ./bin/count-path-start-end.pl data/relation/output/ > tsv/count-path-start-end.tsv
$ ./bin/js/count-path-start-end-tsv2json.js tsv/count-path-start-end.tsv > json/count-path-start-end.json
```

Add attributes
```
$ cat graph/path-count.pg =(./bin/js/togodx-attributes-pg.js) > graph/path-attr.pg
```
