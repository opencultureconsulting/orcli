#!/bin/bash

t="delete-force"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# assertion (project names are matched exactly, not as regex)
cat << "DATA" > "${tmpdir}/${t}.assert"
axb
x:a.b
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "a.b"
orcli import csv "${t}.csv" --projectName "a.b"
orcli import csv "${t}.csv" --projectName "axb"
orcli import csv "${t}.csv" --projectName "x:a.b"
if orcli delete "a.b" 2> "${t}.log"; then
  exit 1
fi
grep -q "multiple projects found" "${t}.log"
orcli delete --force "a.b"
orcli list | cut -d : -f 2- | sort > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
