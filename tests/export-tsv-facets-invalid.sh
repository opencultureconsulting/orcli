#!/bin/bash

t="export-tsv-facets-invalid"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
ERROR: invalid --facets [{ (json array expected)!
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
if orcli export tsv "${t}" --facets '[{' 2> "${t}.log"; then
  exit 1
fi
grep -o 'ERROR: .*' "${t}.log" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
