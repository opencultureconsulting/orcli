#!/bin/bash

t="import-json-guessCellValueTypes"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.json"
[ { "a": "1", "b": 2 } ]
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{ "_ - a": "1", "_ - b": 2 }
{ "_ - a": 1, "_ - b": 2 }
DATA

# action
cd "${tmpdir}" || exit 1
orcli import json "${t}.json" --projectName "${t}-default"
orcli import json "${t}.json" --projectName "${t}" --guessCellValueTypes
orcli export jsonl "${t}-default" > "${t}.output"
orcli export jsonl "${t}" >> "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
