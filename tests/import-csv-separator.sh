#!/bin/bash

t="import-csv-separator"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example-separator.csv "${tmpdir}/${t}.csv"

# assertion
cp data/example.tsv "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --separator "; "
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
