#!/bin/bash

t="search"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
email,name,state,gender,purchase
danny.baron@example1.com,Danny Baron,CA,M,TV
melanie.white@example2.edu,Melanie White,NC,F,iPhone
danny.baron@example1.com,D. Baron,CA,M,Winter jacket
ben.tyler@example3.org,Ben Tyler,NV,M,Flashlight
arthur.duff@example4.com,Arthur Duff,OR,M,Dining table
danny.baron@example1.com,Daniel Baron,CA,M,Bike
jean.griffith@example5.org,Jean Griffith,WA,F,Power drill
melanie.white@example2.edu,Melanie	White,NC,F,iPad
ben.morisson@example6.org,Ben Morisson,FL,M,Amplifier
arthur.duff@example4.com,Arthur Duff,OR,M,Night table
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
melanie.white@example2.edu	name	Melanie White
melanie.white@example2.edu	name	"Melanie	White"
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
orcli search "${t}" "^Mel" --index "email" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
