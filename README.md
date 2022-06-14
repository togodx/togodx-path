# TogoDX path

Graph without labels for relations
* https://togodx.github.io/togodx-path/path-selected.html

Graph with labels for relations
* https://togodx.github.io/togodx-path/path-selected-label.html

TSV file for the list of relations
* https://github.com/togodx/togodx-path/blob/main/graph/path-selected.tsv

Command for reproducing the graph
```
$ ./bin/make_graph.pl > graph/graph-selected.pg
```
```
$ ./bin/make_tsv.pl graph/graph-selected.pg > graph/path-selected.tsv
```
