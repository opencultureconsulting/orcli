#!/bin/bash

t="delete"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion (empty file)
cat << "DATA" > "${tmpdir}/${t}.assert"
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv"
orcli list | grep "${t} csv"
orcli delete "${t} csv"
orcli list | grep "${t} csv" > "${t}.output" || exit 0

# test
diff -u "${t}.assert" "${t}.output"
