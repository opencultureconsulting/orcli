#!/bin/bash

t="export-jsonl-escaping"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
"a""b",c
"x""y",z
DATA

# assertion (quotes in separator and column names)
cat << "DATA" > "${tmpdir}/${t}.assert"
{"a\"b":["x","y"],"c":"z"}
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export jsonl "${t}" --separator '"' > "${t}.output"

# test (as compact JSON, because OpenRefine before 3.6 formats arrays without spaces)
jq -c . "${t}.output" > "${t}.output.json"
diff -u "${t}.assert" "${t}.output.json"
