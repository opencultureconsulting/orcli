#!/bin/bash

t="import-txt-ignoreLines"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.txt "${tmpdir}/${t}.txt"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
foo	bar	baz
1	2	3
0	0	0
$	/	'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import txt "${t}.txt" --projectName "${t}" --columnWidths "1,1" --columnNames "foo,bar,baz" --ignoreLines 1
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
