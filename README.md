# TogoDX path

## v2022-11

Highligh ID conversion path
* https://togodx.github.io/togodx-path/path-highlight-2022-11.html

Show attributes
* https://togodx.github.io/togodx-path/path-attr-2022-11.html

## Previous version

Show ID links
* https://togodx.github.io/togodx-path/path-selected.html

Highligh ID conversion path
* https://togodx.github.io/togodx-path/path-highlight.html

Check ID counts
* https://togodx.github.io/togodx-path/path-count.html

Show attributes
* https://togodx.github.io/togodx-path/path-attr.html

## Data preparation

Create the graph of ID links
```
$ ./bin/create_graph.pl > graph/dataset.pg
$ ./bin/create_graph.pl -l > tsv/dataset-links.tsv
$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```

List paths used in TogoDX/Human
```
$ ./bin/js/paths.js > json/paths.json
```

Count IDs
```
$ ./bin/js/attributes-count-ids.js data/json/ > tsv/attribute-count-ids.tsv
$ ./bin/js/attributes-count-ids.js data/json/ -d > tsv/dataset-count-ids.tsv
$ ./bin/js/attributes-count-ids.js data/json/ -d -j > json/dataset-count-ids.json
$ ./bin/js/attributes-count-ids.js data/json/ -l > tsv/ids.tsv
$ ./bin/id-pairs-count.pl data/relation/output/ > tsv/id-pairs-count.tsv
$ ./bin/js/id-pairs-count-tsv2json.js tsv/id-pairs-count.tsv > json/id-pairs-count.tsv.json
```

Add ID counts
```
$ ./bin/create_graph.pl -c tsv/dataset-count-ids.tsv > graph/dataset-count.pg
```

Add attributes
```
$ cat graph/dataset-count.pg =(./bin/js/attributes-pg.js) > graph/dataset-attr.pg
```

## Supplementary tables

```
$ ./bin/js/attributes-list.js data/json/ > tsv/attribute-list.tsv
$ ./bin/js/attributes-list.js > tsv/attribute-description.tsv
```
* https://github.com/togodx/togodx-path/blob/main/tsv/attribute-count-ids.tsv
* https://github.com/togodx/togodx-path/blob/main/tsv/attribute-list.tsv
* https://github.com/togodx/togodx-path/blob/main/tsv/attribute-description-mod.tsv
