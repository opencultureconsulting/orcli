#!/bin/bash

t="import-csv-encoding"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example-iso-8859-1.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c
1	2	3
ä	é	ß
$	\	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --encoding "ISO-8859-1"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
