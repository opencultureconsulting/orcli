#!/bin/bash

t="completions"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
# orcli completion                                         -*- shell-script -*-
DATA

# action
cd "${tmpdir}" || exit 1
orcli completions | head -n1 > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
