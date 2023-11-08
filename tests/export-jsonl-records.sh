#!/bin/bash
# shellcheck disable=SC1083

t="export-jsonl-records"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
email,name,state,gender,purchase
danny.baron@example1.com,Danny Baron,CA,M,TV
,D. Baron,,,Winter jacket
,Daniel Baron,,,Bike
ben.tyler@example3.org,Ben Tyler,NV,M,Flashlight
melanie.white@example2.edu,Melanie White,NC,F,iPad
,,,,iPhone
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{ "email": "danny.baron@example1.com", "name": [ "Danny Baron", "D. Baron", "Daniel Baron" ], "state": "CA", "gender": "M", "purchase": [ "TV", "Winter jacket", "Bike" ] }
{ "email": "ben.tyler@example3.org", "name": [ "Ben Tyler" ], "state": "NV", "gender": "M", "purchase": [ "Flashlight" ] }
{ "email": "melanie.white@example2.edu", "name": [ "Melanie White" ], "state": "NC", "gender": "F", "purchase": [ "iPad", "iPhone" ] }
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export jsonl "${t}" --output "${t}.output" --mode records

# test
diff -u "${t}.assert" "${t}.output"
