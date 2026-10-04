#!/bin/bash

t="import-jsonl-rename-escaping"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input (quotes and URL special characters in column names)
cat << "DATA" > "${tmpdir}/${t}.jsonl"
{"a&b": 1, "c+d": 2, "e\"%20f": 3}
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
["a&b","c+d","e\"%20f"]
DATA

# action
cd "${tmpdir}" || exit 1
orcli import jsonl "${t}.jsonl" --projectName "${t}" --rename
orcli info "${t}" | jq -c .columns > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
