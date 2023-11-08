#!/bin/bash
# shellcheck disable=SC1083

t="export-jsonl-facets"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/duplicates.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{ "email": "ben.tyler@example3.org", "name": "Ben Tyler", "state": "NV", "gender": "M", "purchase": "Flashlight" }
{ "email": "ben.morisson@example6.org", "name": "Ben Morisson", "state": "FL", "gender": "M", "purchase": "Amplifier" }
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export jsonl "${t}" \
--output "${t}.output" \
--facets '[ { "type": "text", "columnName": "name", "mode": "regex", "caseSensitive": false, "query": "^Ben"  } ]'

# test
diff -u "${t}.assert" "${t}.output"
