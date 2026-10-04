#!/bin/bash

t="import-txt"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.txt "${tmpdir}/${t}.txt"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
Column 1
abc
123
000
$/'
DATA

# action
cd "${tmpdir}" || exit 1
orcli import txt "${t}.txt" --projectName "${t}"
# OpenRefine localizes default column names by the server's language
# (e.g. "Spalte 1"), so normalize them to "Column 1" in the header row
orcli export tsv "${t}" | sed $'1s/[^\t ]* \\([0-9][0-9]*\\)/Column \\1/g' > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
