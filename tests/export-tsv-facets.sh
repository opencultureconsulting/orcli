#!/bin/bash

t="export-tsv-facets"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/duplicates.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
email	name	state	gender	purchase
ben.tyler@example3.org	Ben Tyler	NV	M	Flashlight
ben.morisson@example6.org	Ben Morisson	FL	M	Amplifier
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export tsv "${t}" \
--output "${t}.output" \
--facets '[ { "type": "text", "name": "foo", "columnName": "name", "mode": "regex", "caseSensitive": false, "query": "Ben"  } ]'

# test
diff -u "${t}.assert" "${t}.output"
