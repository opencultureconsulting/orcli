# shellcheck shell=bash
projectid="$(get_id "${args[project]}")"

# assemble specific post data (some options require json format)
data+=("project=${projectid}")
data+=("format=tsv")
options='{ "separator": "\t"'
if [[ ${args[--select]} ]]; then
    options+=", \"columns\": $(jq -cn --arg s "${args[--select]}" '$s | split(",") | map({name: .})')"
fi
options+=' }'
data+=("options=${options}")

# call post_export function to post data and validate results
post_export "${data[@]}"
