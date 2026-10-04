#!/bin/bash

t="import-csv-validation"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
validation error in --limit LIMIT:
must be an integer
DATA

# action
cd "${tmpdir}" || exit 1
if orcli import csv "${t}.csv" --limit "1,5" 2> "${t}.output"; then
  exit 1
fi

# test
diff -u "${t}.assert" "${t}.output"
