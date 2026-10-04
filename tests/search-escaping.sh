#!/bin/bash

t="search-escaping"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
"id ""x""",url
a,https://example.com/b/1
b,https://example.com/c/2
c,https://example.com/b/x
DATA

# assertion (slashes, backslashes and quotes in regex and column name)
cat << "DATA" > "${tmpdir}/${t}.assert"
a	url	https://example.com/b/1
a	url	https://example.com/b/1
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli search "${t}" '/b/\d' --index 'id "x"' > "${t}.output"
orcli search "${t}" '\/b\/\d' --index 'id "x"' >> "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
