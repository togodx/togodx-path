# TogoDX path

ID links between datasets
* https://togodx.github.io/togodx-path/path-selected.html

Highlighting ID conversion path (*beta*)
* https://togodx.github.io/togodx-path/path-highlight.html

Reproducing the graph
```
$ ./bin/make_graph.pl > graph/path-selected.pg

$ rm -rf ./tmp/       # Remove temporary (cached) files after creating graph
```
```
$ ./bin/make_tsv.pl graph/path-selected.pg > graph/path-selected.tsv
```
