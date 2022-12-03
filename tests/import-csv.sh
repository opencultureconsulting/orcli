#!/bin/bash

t="import-csv"

# environment
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15
cp data/example.csv "${tmpdir}"/${t}.csv
cp data/example.tsv "${tmpdir}"/${t}.assert
cd "${tmpdir}" || exit 1

# action
orcli import csv "${t}.csv"
orcli export tsv "${t} csv" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
