#!/bin/bash

t="transform-apply-operations"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,b,c
1,2,3
1,2,3
x,y,z
DATA
# operations available in all supported OpenRefine versions (column-move, row-removal with
# a facet), a multi-line expression and a long-running process with HTTP headers
cat << DATA > "${tmpdir}/${t}.history"
[
  {
    "op": "core/column-move",
    "columnName": "b",
    "index": 0,
    "description": "Move column b to position 0"
  },
  {
    "op": "core/row-removal",
    "engineConfig": {
      "facets": [
        {
          "type": "list",
          "name": "duplicates",
          "columnName": "",
          "expression": "grel:row.index",
          "omitBlank": false,
          "omitError": false,
          "selection": [ { "v": { "v": 1, "l": "1" } } ],
          "selectBlank": false,
          "selectError": false,
          "invert": false
        }
      ],
      "mode": "row-based"
    },
    "description": "Remove rows"
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "c",
    "expression": "grel:value +\n\"!\"",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 10,
    "description": "Text transform on cells in column c"
  },
  {
    "op": "core/column-addition-by-fetching-urls",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "baseColumnName": "a",
    "urlExpression": "grel:\"${OPENREFINE_URL}/command/core/get-version\"",
    "onError": "set-to-blank",
    "newColumnName": "d",
    "columnInsertIndex": 3,
    "delay": 0,
    "cacheResponses": true,
    "httpHeadersJson": [ { "name": "accept", "value": "application/json" } ],
    "description": "Create column d by fetching URLs"
  },
  {
    "op": "core/text-transform",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "d",
    "expression": "grel:isNonBlank(value.parseJson().version)",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 10,
    "description": "Text transform on cells in column d"
  }
]
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
b	a	c	d
2	1	3!	true
y	x	z!	true
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli transform "${t}" "${t}.history"
orcli export tsv "${t}" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
