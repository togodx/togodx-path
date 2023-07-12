# TogoDX path

## v2023-07

ID links
* [index-modified.html](https://togodx.github.io/togodx-path/index-modified.html)

Table of ID links
* [dataset-links-modified.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/dataset-links-modified.tsv)

ID links (with attributes)
* [attr-modified.html](https://togodx.github.io/togodx-path/attr-modified.html)

Paths (JSON)
* [paths-modified.json](https://github.com/togodx/togodx-path/blob/main/json/paths-modified.json)

## v2022-11

ID links
* [path-highlight-2022-11.html](https://togodx.github.io/togodx-path/path-highlight-2022-11.html) (linked from [about](https://togodx.github.io/togodx-config-human/about.html), [usage](https://togodx.github.io/togodx-config-human/usage.html))

Table of ID links
* [dataset-links-2022-11.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/dataset-links-2022-11.tsv) (linked from [about](https://togodx.github.io/togodx-config-human/about.html), [usage](https://togodx.github.io/togodx-config-human/usage.html))

ID links (with attributes)
* [path-attr-label-2022-11.html](https://togodx.github.io/togodx-path/path-attr-label-2022-11.html)

Table of attributes
* [attribute-description-mod-2022-11.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/attribute-description-mod-2022-11.tsv)

Paths (JSON)
* [paths.json](https://github.com/togodx/togodx-path/blob/main/json/paths.json)

## v1.1

ID links
* [path-selected.html](https://togodx.github.io/togodx-path/path-selected.html) (linked from [news v1.1](https://dbcls.rois.ac.jp/ja/2022/06/20/post1.html))

Table of ID links
* [dataset-links.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/dataset-links.tsv) (linked from [news v1.1](https://dbcls.rois.ac.jp/ja/2022/06/20/post1.html))

ID links (with attributes)
* [path-attr-label.html](https://togodx.github.io/togodx-path/path-attr-label.html)

ID links (with ID counts)
* [path-count.html](https://togodx.github.io/togodx-path/path-count.html)

Table of attributes
* [attribute-description-mod.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/attribute-description-mod.tsv)
* [attribute-count-ids.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/attribute-count-ids.tsv)
* [attribute-list.tsv](https://github.com/togodx/togodx-path/blob/main/tsv/attribute-list.tsv)

## Data preparation

Get paths
```
$ ./bin/js/paths.js > json/paths.json
```

Create graph data
```
$ ./bin/create_graph.pl json/paths.json > graph/dataset.pg
$ ./bin/create_graph.pl -l json/paths.json > tsv/dataset-links.tsv
$ ./bin/create_graph.pl -a json/paths.json > graph/dataset-attr.pg
```

### Optional:

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

Creating supplementary tables
```
$ ./bin/js/attributes-list.js data/json/ > tsv/attribute-list.tsv
$ ./bin/js/attributes-description.js > tsv/attribute-description.tsv
```

## Test modified paths

Edit `json/paths-modified.json`

Update graph:
```
$ ./bin/create_graph.pl json/paths-modified.json > graph/dataset-modified.pg
$ ./bin/create_graph.pl -a json/paths-modified.json > graph/dataset-attr-modified.pg
```

Update tsv (to be referred by html):
```
$ ./bin/create_graph.pl -l json/paths-modified.json > tsv/dataset-links-modified.tsv
```

Test:
* Access index-modified.html or attr-modified.html
  * Start HTTP server `$ python3 -m http.server`, and access localhost:8000/index-modified.html
  * Push modifications, and access https://togodx.github.io/togodx-path/index-modified.html
