#!/bin/bash

t="import-csv-blankCellsAsStrings"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,b,c
1,2,3
0,,0
$,\,'
DATA

cat << "DATA" > "${tmpdir}/${t}.transform"
[
  {
    "op": "core/text-transform",
    "engineConfig": {
      "facets": [],
      "mode": "row-based"
    },
    "columnName": "b",
    "expression": "grel:isNull(value)",
    "onError": "keep-original",
    "repeat": false,
    "repeatCount": 10
  }
]
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c
1	false	3
0	false	0
$	false	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --blankCellsAsStrings
orcli transform "${t}" "${tmpdir}/${t}.transform"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
