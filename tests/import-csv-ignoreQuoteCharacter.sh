#!/bin/bash

t="import-csv-ignoreQuoteCharacter"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.csv"
a,b,c
1,"2,0",3
0,0,0
$,/,'
DATA

# assertion
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c	Column 4
1	"2	0"	3
0	0	0	
$	/	'	
DATA
# OpenRefine before 3.7 removes the quote characters
# and 3.7 quotes special characters on export
case "$(curl -fs "${OPENREFINE_URL}/command/core/get-version" | jq -r '.version')" in
  3.[3-6] | 3.[3-6].*) sed -i '2s/.*/1\t2\t0\t3/' "${tmpdir}/${t}.assert" ;;
  3.7 | 3.7.*) sed -i '2s/.*/1\t"""2"\t"0"""\t3/' "${tmpdir}/${t}.assert" ;;
esac

# action
cd "${tmpdir}" || exit 1
# OpenRefine 4.x fails without headerLines manually set
orcli import csv "${t}.csv" --projectName "${t}" --ignoreQuoteCharacter --headerLines 1
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
