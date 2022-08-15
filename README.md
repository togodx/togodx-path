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
$ ./bin/make_graph.pl > graph/dataset.pg
$ ./bin/make_graph.pl -l > tsv/dataset-links.tsv
$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```

Reproducing the path used in TogoDX/Human
```
$ ./bin/js/togodx-path.js > json/paths.json
```

Count IDs
```
$ ./bin/js/togodx-count-ids.js data/json/ > tsv/attribute-count-ids.tsv
$ ./bin/js/togodx-count-ids.js data/json/ -d > tsv/dataset-count-ids.tsv
$ ./bin/js/togodx-count-ids.js data/json/ -d -j > json/dataset-count-ids.json
$ ./bin/js/togodx-count-ids.js data/json/ -l > tsv/ids.tsv
$ (cd data/relation/output; wc -l *.csv) | grep -v total | perl -pe 's/^\s*(\d+)\s(\S+)\.csv$/$2\t$1/' > json/paths-count.tsv
$ ./bin/js/paths-count-tsv2json.js json/paths-count.tsv > json/paths-count.json
$ ./bin/count-path-start-end.pl data/relation/output/ > json/count-path-start-end.tsv
$ ./bin/js/count-path-start-end-tsv2json.js json/count-path-start-end.tsv > json/count-path-start-end.json
```

Add ID counts
```
$ ./bin/make_graph.pl -c tsv/dataset-count-ids.tsv > graph/dataset-count.pg
```

Add attributes
```
$ cat graph/dataset-count.pg =(./bin/js/togodx-attributes-pg.js) > graph/dataset-attr.pg
```
