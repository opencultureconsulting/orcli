# shellcheck shell=bash
projectid="$(get_id "${args[project]}")"
separator="${args[--separator]:-,}"

# assemble specific post data (some options require json format)
data+=("project=${projectid}")
data+=("format=csv")
# interpret backslash escapes like the importers do (e.g. \t for tab)
separator="$(printf '%bx' "${separator}")"
options="{ \"separator\": $(json_string "${separator%x}")"
if [[ ${args[--select]} ]]; then
    options+=", \"columns\": $(jq -cn --arg s "${args[--select]}" '$s | split(",") | map({name: .})')"
fi
options+=' }'
data+=("options=${options}")

# call post_export function to post data and validate results
post_export "${data[@]}"
