# TogoDX path

Graph without labels for relations
* https://togodx.github.io/togodx-path/path-selected.html

Graph with labels for relations
* https://togodx.github.io/togodx-path/path-selected-label.html

TSV file for the list of relations
* https://github.com/togodx/togodx-path/blob/main/graph/path-selected.tsv

Command for reproducing the graph
```
$ ./bin/make_graph.pl > graph/path-selected.pg
$ rm -rf ./tmp/ # remove cached files
```
```
$ ./bin/make_tsv.pl graph/path-selected.pg > graph/path-selected.tsv
```
