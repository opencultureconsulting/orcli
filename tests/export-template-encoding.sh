#!/bin/bash

t="export-template-encoding"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
printf 'a,b,c\n1,2,3\nä,é,ß\n$,/,'"'"'\n' > "${tmpdir}/${t}.csv"
cat << "DATA" > "${tmpdir}/${t}.template"
{{cells["a"].value}},{{cells["b"].value}},{{cells["c"].value}}
DATA

# assertion
tail -n +2 data/example-iso-8859-1.csv > "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export template "${t}" "${t}.template" --separator $'\n' --suffix $'\n' --encoding "ISO-8859-1" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
