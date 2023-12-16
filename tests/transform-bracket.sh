#!/bin/bash

t="transform-bracket"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
email	name	test	state	gender	purchase
danny.baron@example1.com	Danny Baron	(Danny Baron)	CA	M	TV
melanie.white@example2.edu	Melanie White	(Melanie White)	NC	F	iPhone
danny.baron@example1.com	D. Baron	(D. Baron)	CA	M	Winter jacket
ben.tyler@example3.org	Ben Tyler	(Ben Tyler)	NV	M	Flashlight
arthur.duff@example4.com	Arthur Duff	(Arthur Duff)	OR	M	Dining table
danny.baron@example1.com	Daniel Baron	(Daniel Baron)	CA	M	Bike
jean.griffith@example5.org	Jean Griffith	(Jean Griffith)	WA	F	Power drill
melanie.white@example2.edu	Melanie White	(Melanie White)	NC	F	iPad
ben.morisson@example6.org	Ben Morisson	(Ben Morisson)	FL	M	Amplifier
arthur.duff@example4.com	Arthur Duff	(Arthur Duff)	OR	M	Night table
DATA

# transform
cat << "DATA" > "${tmpdir}/${t}.history"
[
  {
    "op": "core/column-addition",
    "engineConfig": {
      "facets": [],
      "mode": "row-based"
    },
    "baseColumnName": "name",
    "expression": "grel:forNonBlank(value, x, '(' + x + ')', null)",
    "newColumnName": "test",
    "columnInsertIndex": 2
  }
]
DATA

# action
cd "${tmpdir}" || exit 1
orcli import csv "https://git.io/fj5hF" --projectName "${t}"
orcli transform "${t}" "${t}.history"
orcli export tsv "${t}" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
