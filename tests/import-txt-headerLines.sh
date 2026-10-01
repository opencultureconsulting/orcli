#!/bin/bash

t="import-txt-headerLines"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.txt "${tmpdir}/${t}.txt"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
Column 1	Column 2	Column 3
a	b	c
1	2	3
0	0	0
$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import txt "${t}.txt" --projectName "${t}" --columnWidths "1,1" --headerLines 0
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
