#!/bin/bash

t="import-csv-escaping"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
{
  "name": "say \"hi\" \\ bye",
  "tags": [
    "a\"b",
    "c\\d"
  ],
  "columns": [
    "x\"",
    "y\\",
    "z"
  ]
}
x"	y\\	z
1	2	3
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName 'say "hi" \ bye' --projectTags 'a"b,c\d' --columnNames 'x",y\,z' --ignoreLines 1
orcli info "$(orcli list | grep -F 'say' | cut -d : -f 1)" | jq '{name, tags, columns}' > "${t}.output"
orcli export tsv "$(orcli list | grep -F 'say' | cut -d : -f 1)" | head -n 2 >> "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
