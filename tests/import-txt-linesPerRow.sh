#!/bin/bash

t="import-txt-linesPerRow"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.txt "${tmpdir}/${t}.txt"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
Column 1	Column 2
abc	123
000	$/'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import txt "${t}.txt" --projectName "${t}" --linesPerRow 2
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
