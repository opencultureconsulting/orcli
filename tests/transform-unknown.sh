#!/bin/bash

t="transform-unknown"

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "${tmpdir}"; }' 0 2 3 15

# input
cp data/example.csv "${tmpdir}/${t}.csv"
cat << "DATA" > "${tmpdir}/${t}.history"
[
  {
    "op": "core/unknown-operation",
    "columnName": "a",
    "description": "Unknown operation"
  }
]
DATA

# assertion (OpenRefine rejects unknown operations since 3.9 and reports clearer errors since 3.10)
case "$(curl -fs "${OPENREFINE_URL}/command/core/get-version" | jq -r '.version')" in
  3.[3-6] | 3.[3-8].*) response="operation was not applied (unknown operation or invalid parameters?)" ;;
  3.9.*) response="java.lang.IllegalArgumentException: Unknown operation type: core/unknown-operation" ;;
  *) response="Operation #1: Unknown operation core/unknown-operation" ;;
esac
echo "  Response: ${response}" > "${tmpdir}/${t}.assert"

# action
cd "${tmpdir}" || exit 1
orcli import csv "${t}.csv" --projectName "${t}"
if orcli transform "${t}" "${t}.history" 2> "${t}.log"; then
  exit 1
fi
grep -a 'Response:' "${t}.log" > "${t}.output"

# test
diff -u "${t}.assert" "${t}.output"
