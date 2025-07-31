# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# exit if stdin is selected but not present
if [[ ${file} == '-' ]]; then
    if ! read -u 0 -t 0; then
        sleep 1
        if ! read -u 0 -t 0; then
            orcli_import_jsonl_usage
            exit 1
        fi
    fi
fi

# assemble specific post data (some options require json format)
data+=("format=text/json")
options='{ '
options+="\"recordPath\": [\"_\"]"
if [[ ${args[--guessCellValueTypes]} ]]; then
    options+=', '
    options+='"guessCellValueTypes": true'
fi
if [[ ${args[--includeFileSources]} ]]; then
    options+=', '
    options+='includeFileSources: true'
fi
if [[ ${args[--includeArchiveFileName]} ]]; then
    options+=', '
    options+='"includeArchiveFileName": true'
fi
if [[ ${args[--limit]} ]]; then
    options+=', '
    options+="\"limit\": ${args[--limit]}"
fi
if [[ ${args[--storeEmptyStrings]} ]]; then
    options+=', '
    options+='"storeEmptyStrings": true'
fi
if [[ ${args[--projectName]} ]]; then
    options+=', '
    options+="\"projectName\": \"${args[--projectName]}\""
fi
if [[ ${args[--projectTags]} ]]; then
    IFS=',' read -ra projectTags <<< "${args[--projectTags]}"
    options+=', '
    options+="\"projectTags\": [ $(printf ',"'%s'"' "${projectTags[@]}" | cut -c2-) ]"
fi
if [[ ${args[--trimStrings]} ]]; then
    options+=', '
    options+='"trimStrings": true'
fi
options+=' }'
data+=("options=${options}")

# call post_import function to post data and validate results
post_import "${data[@]}"
