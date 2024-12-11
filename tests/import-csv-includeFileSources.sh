#!/bin/bash

t="import-csv-includeFileSources"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}-1.csv"
cp data/example.csv "${tmpdir}/${t}-2.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
File	a	b	c
import-csv-includeFileSources-1.csv	1	2	3
import-csv-includeFileSources-1.csv	0	0	0
import-csv-includeFileSources-1.csv	$	/	'
import-csv-includeFileSources-2.csv	1	2	3
import-csv-includeFileSources-2.csv	0	0	0
import-csv-includeFileSources-2.csv	$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}-1.csv" "${t}-2.csv" --projectName "${t}" --includeFileSources
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
