#!/bin/bash

# environment
t="$(basename "$(pwd)" .sh)"

# data
cat << "DATA" > "${t}.csv"
a,b,c
1,2,3
0,0,0
$,\,'
DATA

# assertion
cat << "DATA" > "${t}.assert"
a	b	c
1	2	3
0	0	0
$	\	'
DATA

# action
orcli import csv "${t}.csv"
orcli export tsv "${t} csv" --output "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"