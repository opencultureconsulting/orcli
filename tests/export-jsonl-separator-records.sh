#!/bin/bash

t="export-jsonl-separator-records"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
conflicting options: --separator cannot be used with --mode records
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
if orcli export jsonl "${t}" --separator ";" --mode records 2> "${t}.output"; then
  exit 1
fi

# test
diff -u "${t}.assert" "${t}.output"
