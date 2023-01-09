#!/bin/bash

t="import-tsv"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.tsv "${tmpdir}/${t}.tsv"

# assertion
cp data/example.tsv "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import tsv "${t}.tsv" --projectName "${t}"
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
