#!/bin/bash

t="sort-columns"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
name	state	email	gender	purchase
Danny Baron	CA	danny.baron@example1.com	M	TV
Melanie White	NC	melanie.white@example2.edu	F	iPhone
D. Baron	CA	danny.baron@example1.com	M	Winter jacket
Ben Tyler	NV	ben.tyler@example3.org	M	Flashlight
Arthur Duff	OR	arthur.duff@example4.com	M	Dining table
Daniel Baron	CA	danny.baron@example1.com	M	Bike
Jean Griffith	WA	jean.griffith@example5.org	F	Power drill
Melanie White	NC	melanie.white@example2.edu	F	iPad
Ben Morisson	FL	ben.morisson@example6.org	M	Amplifier
Arthur Duff	OR	arthur.duff@example4.com	M	Night table
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
orcli sort columns "duplicates" --first name --first state
orcli export tsv "duplicates" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
