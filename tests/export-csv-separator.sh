#!/bin/bash

t="export-csv-separator"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a;b;c
1;2;3
0;0;0
$;/;'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export csv "${t}" --separator ";" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
