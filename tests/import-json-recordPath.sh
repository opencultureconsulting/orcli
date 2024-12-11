#!/bin/bash

t="import-json-recordPath"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.json"
{
   "rows":[
      {
         "a":1,
         "b":2,
         "c":3
      },
      {
         "a":0,
         "b":0,
         "c":0
      },
      {
         "a":"$",
         "b":"/",
         "c":"'"
      }
   ]
}
DATA

# assertion
cp data/example.tsv "${tmpdir}/${t}.assert"
sed -i 's/a	b	c/_ - a	_ - b	_ - c/' "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import json "${t}.json" --projectName "${t}" --recordPath '["_", "rows", "_"]'
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
