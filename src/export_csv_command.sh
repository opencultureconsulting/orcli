# shellcheck shell=bash
inspect_args
projectid="$(get_id "${args[project]}")"
separator="${args[--separator]:-,}"

# assemble specific post data (some options require json format)
data+=("project=${projectid}")
data+=("format=csv")
options='{ '
options+="\"separator\": \"${separator}\""
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": \"${args[--encoding]}\""
fi
if [[ ${args[--select]} ]]; then
    options+=', '
    options+='"columns": ['
    IFS=',' read -ra columns <<< "${args[--select]}"
    options+='{"name":"'
    options+="${columns[0]}"
    options+='"}'
    for cn in "${columns[@]:1}"; do
        options+=', '
        options+='{"name":"'
        options+="${cn}"
        options+='"}'
    done
    options+="]"
fi
options+=' }'
data+=("options=${options}")

# call post_export function to post data and validate results
post_export "${data[@]}"
