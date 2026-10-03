#!/bin/bash

t="import-csv-includeArchiveFileName"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}-1.csv"
cp data/example.csv "${tmpdir}/${t}-2.csv"

# assertion (OpenRefine supports includeArchiveFileName since 3.5)
case "$(curl -fs "${OPENREFINE_URL}/command/core/get-version" | jq -r '.version')" in
  3.[34] | 3.[34].*)
cat << "DATA" > "${tmpdir}/${t}.assert"
a	b	c
1	2	3
0	0	0
$	/	'
1	2	3
0	0	0
$	/	'
DATA
    ;;
  *)
cat << "DATA" > "${tmpdir}/${t}.assert"
Archive	a	b	c
Untitled.zip	1	2	3
Untitled.zip	0	0	0
Untitled.zip	$	/	'
Untitled.zip	1	2	3
Untitled.zip	0	0	0
Untitled.zip	$	/	'
DATA
    ;;
esac

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}-1.csv" "${t}-2.csv" --projectName "${t}" --includeArchiveFileName
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
