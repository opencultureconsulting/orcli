#!/bin/bash

t="transform"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cp data/duplicates-transformed.tsv "${tmpdir}/${t}.assert"

# transform
cp data/duplicates-history.json "${tmpdir}/${t}.history"

# action
cd "${tmpdir}" || exit 1
orcli import csv "https://git.io/fj5hF" --projectName "${t}"
orcli transform "${t}" "${t}.history"
orcli export tsv "${t}" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
