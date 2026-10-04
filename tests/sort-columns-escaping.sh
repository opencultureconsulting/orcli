#!/bin/bash

t="sort-columns-escaping"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,"z""&+",b
1,2,3
DATA

# assertion (quotes and URL special characters in column names)
cat << "DATA" > "${tmpdir}/${t}.assert"
["z\"&+","a","b"]
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli sort columns "${t}" --first 'z"&+'
orcli info "${t}" | jq -c .columns > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
