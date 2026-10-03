#!/bin/bash

t="import-txt-trimStrings"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cat << "DATA" > "${tmpdir}/${t}.txt"
a  b  c
 1  2  3
0  0  0
$  /  '
DATA

# assertion
cp data/example.tsv "${tmpdir}/${t}.assert"
# OpenRefine supports trimStrings since 3.4
case "$(curl -fs "${OPENREFINE_URL}/command/core/get-version" | jq -r '.version')" in
  3.3 | 3.3.*) printf '%s\n' 'a	b	c' ' 1 	 2 	 3' '0  	0  	0' "$  	/  	'" > "${tmpdir}/${t}.assert" ;;
esac

# action
cd "${tmpdir}" || exit 1
orcli import txt "${t}.txt" --projectName "${t}" --columnWidths "3,3" --trimStrings
orcli export tsv "${t}" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
