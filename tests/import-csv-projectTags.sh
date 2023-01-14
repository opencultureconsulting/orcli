#!/bin/bash

t="import-csv-projectTags"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
foo
bar
baz
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --projectTags "foo,bar,baz"
orcli info "${t}" | jq -r .tags[] > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
