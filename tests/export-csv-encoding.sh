#!/bin/bash

t="export-csv-encoding"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
printf 'a,b,c\n1,2,3\nä,é,ß\n$,/,'"'"'\n' > "${tmpdir}/${t}.csv"

# assertion
cp data/example-iso-8859-1.csv "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export csv "${t}" --encoding "ISO-8859-1" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
