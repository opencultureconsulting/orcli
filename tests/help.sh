#!/bin/bash

t="help"

# environment
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15
cd "${tmpdir}" || exit 1

# assertion
cat << "DATA" > "${t}.assert"
orcli - OpenRefine command-line interface written in Bash
DATA

# action
orcli --help | head -n1 > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
