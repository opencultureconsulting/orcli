#!/bin/bash

t="import-csv-ignoreQuoteCharacter"

# disable test temporarily
# https://github.com/opencultureconsulting/orcli/issues/132
exit 0

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,b,c
1,"2,0",3
0,0,0
$,/,'
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c	Column 4
1	2	0	3
0	0	0	
$	/	'	
DATA

# action
cd "${tmpdir}" || exit 1
# OpenRefine 4.x fails without headerLines manually set
orcli import csv "${t}.csv" --projectName "${t}" --ignoreQuoteCharacter --headerLines 1
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
