#!/bin/bash

t="export-tsv-select"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/duplicates.csv "${tmpdir}/${t}.csv"

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
name	email	purchase
Danny Baron	danny.baron@example1.com	TV
Melanie White	melanie.white@example2.edu	iPhone
D. Baron	danny.baron@example1.com	Winter jacket
Ben Tyler	ben.tyler@example3.org	Flashlight
Arthur Duff	arthur.duff@example4.com	Dining table
Daniel Baron	danny.baron@example1.com	Bike
Jean Griffith	jean.griffith@example5.org	Power drill
Melanie White	melanie.white@example2.edu	iPad
Ben Morisson	ben.morisson@example6.org	Amplifier
Arthur Duff	arthur.duff@example4.com	Night table
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli export tsv "${t}" \
--output "${t}.output" \
--select "name,email,purchase"

# test
diff -u "${t}.assert" "${t}.output"
