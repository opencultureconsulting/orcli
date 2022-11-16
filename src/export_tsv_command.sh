# shellcheck shell=bash
projectid="$(get_id "${args[project]}")"
separator='\t'

# assemble specific post data (some options require json format)
data+=("project=${projectid}")
data+=("format=tsv")
options='{ '
options+="\"separator\": \"${separator}\""
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": \"${args[--encoding]}\""
fi
options+=' }'
data+=("options=${options}")

# call post_export function to post data and validate results
post_export "${data[@]}"
