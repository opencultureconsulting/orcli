#!/bin/bash

t="sort-columns-first-missing"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
ERROR: sorting columns in sort-columns-first-missing failed!
  Response: column(s) ["foo"] not found
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
if orcli sort columns "${t}" --first a --first foo 2> "${t}.log"; then
  exit 1
fi
sed -n 's/^\[.*\] ERROR/ERROR/p; /^  Response/p' "${t}.log" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
