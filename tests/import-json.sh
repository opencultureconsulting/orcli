#!/bin/bash

t="import-json"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.json "${tmpdir}/${t}.json"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
_ - a	_ - b	_ - c
1	2	3
0	0	0
$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import json "${t}.json" --projectName "${t}"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
