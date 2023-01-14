#!/bin/bash

t="import-csv"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cp data/example.tsv "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
