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
$ ./bin/js/paths.js > json/paths.json
```

Count IDs
```
$ ./bin/js/dataset-count-ids.js data/json/ > tsv/attribute-count-ids.tsv
$ ./bin/js/dataset-count-ids.js data/json/ -d > tsv/dataset-count-ids.tsv
$ ./bin/js/dataset-count-ids.js data/json/ -d -j > json/dataset-count-ids.json
$ ./bin/js/dataset-count-ids.js data/json/ -l > tsv/ids.tsv
$ ./bin/check_ids_in_paths.pl data/relation/output/ > tsv/id-pairs-count.tsv
$ ./bin/js/count-path-start-end-tsv2json.js json/id-pairs-count.tsv > json/count-path-start-end.json
$ ./bin/js/count-path-start-end-tsv2json.js tsv/id-pairs-count.tsv -c > json/paths-count.json
```

Add ID counts
```
$ ./bin/make_graph.pl -c tsv/dataset-count-ids.tsv > graph/dataset-count.pg
```

Add attributes
```
$ cat graph/dataset-count.pg =(./bin/js/attributes-pg.js) > graph/dataset-attr.pg
```
