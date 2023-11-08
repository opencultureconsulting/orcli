#!/bin/bash
# shellcheck disable=SC1083

t="export-jsonl-separator"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/duplicates.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{ "email": "danny.baron@example1.com", "name": [ "Danny", "Baron" ], "state": "CA", "gender": "M", "purchase": [ "TV" ] }
{ "email": "melanie.white@example2.edu", "name": [ "Melanie", "White" ], "state": "NC", "gender": "F", "purchase": [ "iPhone" ] }
{ "email": "danny.baron@example1.com", "name": [ "D.", "Baron" ], "state": "CA", "gender": "M", "purchase": [ "Winter", "jacket" ] }
{ "email": "ben.tyler@example3.org", "name": [ "Ben", "Tyler" ], "state": "NV", "gender": "M", "purchase": [ "Flashlight" ] }
{ "email": "arthur.duff@example4.com", "name": [ "Arthur", "Duff" ], "state": "OR", "gender": "M", "purchase": [ "Dining", "table" ] }
{ "email": "danny.baron@example1.com", "name": [ "Daniel", "Baron" ], "state": "CA", "gender": "M", "purchase": [ "Bike" ] }
{ "email": "jean.griffith@example5.org", "name": [ "Jean", "Griffith" ], "state": "WA", "gender": "F", "purchase": [ "Power", "drill" ] }
{ "email": "melanie.white@example2.edu", "name": [ "Melanie", "White" ], "state": "NC", "gender": "F", "purchase": [ "iPad" ] }
{ "email": "ben.morisson@example6.org", "name": [ "Ben", "Morisson" ], "state": "FL", "gender": "M", "purchase": [ "Amplifier" ] }
{ "email": "arthur.duff@example4.com", "name": [ "Arthur", "Duff" ], "state": "OR", "gender": "M", "purchase": [ "Night", "table" ] }
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export jsonl "${t}" --output "${t}.output" --separator ' '

# test
diff -u "${t}.assert" "${t}.output"
