#!/bin/bash

t="import-csv-skipBlankRows"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,b,c
1,2,3
,,
$,/,'
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c
1	2	3
$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}" --skipBlankRows
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
