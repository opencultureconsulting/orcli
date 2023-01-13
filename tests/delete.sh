#!/bin/bash

t="delete"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion (empty file)
touch "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli list | grep "${t}"
orcli delete "${t}"
orcli list | grep "${t}" > "${t}.output" || exit 0
orcli import csv "${t}.csv" --projectName "${t}"
orcli import csv "${t}.csv" --projectName "${t}"
orcli list | grep "${t}"
orcli delete --force "${t}"
orcli list | grep "${t}" >> "${t}.output" || exit 0

# test
diff -u "${t}.assert" "${t}.output"
