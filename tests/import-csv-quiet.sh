#!/bin/bash

t="import-csv-quiet"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion (empty file)
touch "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --quiet &> "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
