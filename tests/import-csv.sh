#!/bin/bash

# environment
t=import-csv
mkdir "${OPENREFINE_TMPDIR}/${t}"
cd "${OPENREFINE_TMPDIR}/${t}" || exit 1

# data
cat << "DATA" > "test.csv"
a,b,c
1,2,3
0,0,0
$,\,'
DATA

# assertion
cat << "DATA" > "test.assert"
a	b	c
1	2	3
0	0	0
$	\	'
DATA

# action
orcli import csv "test.csv"
orcli export tsv "test csv" --output "test.output"

# test
diff -u "test.assert" "test.output"