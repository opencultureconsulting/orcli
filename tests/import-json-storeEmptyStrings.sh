#!/bin/bash

t="import-json-storeEmptyStrings"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.json"
[
    {
      "a": 1,
      "b": 2,
      "c": 3
    },
    {
      "a": "",
      "b": "",
      "c": ""
    },
    {
      "a": "$",
      "b": "/",
      "c": "'"
    }
]
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
_ - a	_ - b	_ - c
1	2	3
		
$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import json "${t}.json" --projectName "${t}" --storeEmptyStrings
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
