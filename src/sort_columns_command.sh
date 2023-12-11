# get columns, sort and transform with re-order columns
# shellcheck shell=bash

# catch args, convert the space delimited string to an array
first=()
eval "first=(${args[--first]})"
# convert to a comma-separated list of elements
columns=$(printf ',"'%s'"' "${first[@]}" | cut -c2-)

# get project id
projectid="$(get_id "${args[project]}")"

csrf="$(get_csrf)"
if ! sorted=$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq --argjson columns "[ ${columns} ]" '($columns) + ([ .[].name ] | del (.[] | select (. | IN( $columns[] ))) | sort)'); then
    error "getting columns in ${args[project]} failed!"
fi
if ! curl -fs -o /dev/null --data project="$projectid" --data "columnNames=${sorted}" "${OPENREFINE_URL}/command/core/reorder-columns${csrf}"; then
    error "sorting columns in ${args[project]} failed!"
fi
log "sorted columns in ${args[project]}"