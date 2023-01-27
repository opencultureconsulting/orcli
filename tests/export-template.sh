#!/bin/bash
# shellcheck disable=SC1083

t="export-template"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/duplicates.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{ "events" : [{ "name" : "Ben Tyler", "purchase" : "Flashlight" }
,{ "name" : "Ben Morisson", "purchase" : "Amplifier" }
]}
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export template "${t}" --output "${t}.output" \
<<< '{ "name" : {{jsonize(cells["name"].value)}}, "purchase" : {{jsonize(cells["purchase"].value)}} }' \
--prefix '{ "events" : [' \
--separator , \
--mode rows \
--suffix ]}$'\n' \
--facets '[ { "type": "text", "name": "foo", "columnName": "name", "mode": "regex", "caseSensitive": false, "query": "Ben" } ]'

# test
diff -u "${t}.assert" "${t}.output"
