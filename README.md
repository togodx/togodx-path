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
