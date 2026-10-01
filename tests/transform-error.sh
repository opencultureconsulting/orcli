#!/bin/bash

t="transform-error"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"
cat << "DATA" > "${tmpdir}/${t}.history"
[
  {
    "op": "core/column-split",
    "engineConfig": { "facets": [], "mode": "row-based" },
    "columnName": "a",
    "description": "Split column a"
  }
]
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
  Response: Operation #1: Missing field lengths
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
if orcli transform "${t}" "${t}.history" 2> "${t}.log"; then
  exit 1
fi
grep -a 'Response:' "${t}.log" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
