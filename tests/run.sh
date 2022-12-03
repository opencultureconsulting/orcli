#!/bin/bash

t="run"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cp data/duplicates-transformed.tsv "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli run --memory "2000M" --port "3334" << EOF
orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
orcli transform "duplicates" "https://git.io/fj5ju"
orcli export tsv "duplicates" --output "${t}.output"
EOF

# test
diff -u "${t}.assert" "${t}.output"