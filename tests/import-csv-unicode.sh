#!/bin/bash

t="import-csv-unicode biểu tượng cảm xúc ⛲"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
⌨,code,meaning
⛲,1F347,FOUNTAIN
⛳,1F349,FLAG IN HOLE
⛵,1F352,SAILBOAT
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
⌨	code	meaning
⛲	1F347	FOUNTAIN
⛳	1F349	FLAG IN HOLE
⛵	1F352	SAILBOAT
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
