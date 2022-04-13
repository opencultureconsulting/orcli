# shellcheck shell=bash

# call init_import function to eval args and to set basic post data
init_import

# check if stdin is present if selected
if [[ ${args[file]} == '-' ]] || [[ ${args[file]} == '"-"' ]] && [ -t 0 ]; then
    orcli_import_csv_usage
    exit 1
fi

# assemble specific post data (some options require json format)
data+=("format=text/line-based/*sv")
options='{ '
options+="\"separator\": \"${args[--separator]}\""
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": \"${args[--encoding]}\""
fi
if [[ ${args[--trimStrings]} ]]; then
    options+=', '
    options+="\"trimStrings\": true"
fi
options+=' }'
data+=("options=${options}")

# call post_import function to post data and validate results
post_import "${data[@]}"
