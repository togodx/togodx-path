# TogoDX path

Graph without labels for relations
* https://togodx.github.io/togodx-path/path-selected.html

Graph with labels for relations
* https://togodx.github.io/togodx-path/path-selected-label.html

TSV file for the list of relations
* https://github.com/togodx/togodx-path/blob/main/graph/path-selected.tsv

Reproducing the graph
```
$ ./bin/make_graph.pl > graph/path-selected.pg

$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```
```
$ ./bin/make_tsv.pl graph/path-selected.pg > graph/path-selected.tsv
```
