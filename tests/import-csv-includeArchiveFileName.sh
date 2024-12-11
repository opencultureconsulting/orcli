#!/bin/bash

t="import-csv-includeArchiveFileName"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}-1.csv"
cp data/example.csv "${tmpdir}/${t}-2.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
Archive	a	b	c
Untitled.zip	1	2	3
Untitled.zip	0	0	0
Untitled.zip	$	/	'
Untitled.zip	1	2	3
Untitled.zip	0	0	0
Untitled.zip	$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}-1.csv" "${t}-2.csv" --projectName "${t}" --includeArchiveFileName
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
