#!/bin/bash

t="info"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv"
orcli info "${t} csv"

# test
# grep "${t}" "${t}.output"
