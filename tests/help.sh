#!/bin/bash

t="help"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
orcli - OpenRefine command-line interface written in Bash
DATA

# action
cd "${tmpdir}" || exit 1
orcli --help | head -n1 > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
