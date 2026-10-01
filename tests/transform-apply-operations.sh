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
# operations without specific endpoint (column-move-left, row-duplicate-removal),
# a multi-line expression and a long-running process with HTTP headers
cat << DATA > "${tmpdir}/${t}.history"
[
  {
    "op": "core/column-move-left",
    "columnName": "b",
    "description": "Move column b to the left"
  },
  {
    "op": "core/row-duplicate-removal",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "criteria": [ "a", "b", "c" ],
    "description": "Remove duplicates"
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
