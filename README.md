# TogoDX path

Graph without labels for relations
* https://togodx.github.io/togodx-path/path-selected.html

Graph with labels for relations
* https://togodx.github.io/togodx-path/path-selected-label.html

TSV file for the list of relations
* https://github.com/togodx/togodx-path/blob/main/path-selected.tsv

Command for reproducing the graph
```
$ ./bin/make_graph.pl > path/graph-selected.pg
```
```
$ ./bin/make_tsv.pl path/graph-selected.pg > path-selected.tsv
```
