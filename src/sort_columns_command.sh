# get columns, sort and transform with re-order columns
# shellcheck shell=bash disable=SC2154

# catch args, convert the space delimited string to an array
first=()
eval "first=(${args[--first]})"
# convert to a json array
columns=""
for c in "${first[@]}"; do
    columns+="${columns:+,}$(json_string "$c")"
done

# get project id
projectid="$(get_id "${args[project]}")"

# put --first column(s) in front of all other columns sorted alphabetically
# (first line: --first columns that do not exist, second line: sorted columns)
if ! sorting="$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq -c --argjson first "[ ${columns} ]" '[ .[].name ] | ($first - .), ($first + ((. - $first) | sort))')"; then
    error "getting columns in ${args[project]} failed!"
fi
missing="${sorting%%$'\n'*}"
sorted="${sorting#*$'\n'}"
if [[ $missing != "[]" ]]; then
    error "sorting columns in ${args[project]} failed!" "Response: column(s) ${missing} not found"
fi
if ! post_command reorder-columns "project=${projectid}" "columnNames=${sorted}"; then
    error "sorting columns in ${args[project]} failed!" "Response: ${response_message}"
fi
log "sorted columns in ${args[project]}"
