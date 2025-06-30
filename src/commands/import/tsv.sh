# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# check if stdin is present if selected
if [[ ${file} == '-' ]] && ! read -u 0 -t 0; then
    orcli_import_tsv_usage
    exit 1
fi

# assemble specific post data (some options require json format)
data+=("format=text/line-based/*sv")
options='{ '
options+="\"separator\": \"\\t\""
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": \"${args[--encoding]}\""
fi
if [[ ${args[--blankCellsAsStrings]} ]]; then
    options+=', '
    options+='"storeBlankCellsAsNulls": false'
fi
if [[ ${args[--columnNames]} ]]; then
    IFS=',' read -ra columnNames <<< "${args[--columnNames]}"
    options+=', '
    options+="\"columnNames\": [ $(printf ',"'%s'"' "${columnNames[@]}" | cut -c2-) ]"
fi
if [[ ${args[--guessCellValueTypes]} ]]; then
    options+=', '
    options+='"guessCellValueTypes": true'
fi
if [[ ${args[--headerLines]} ]]; then
    options+=', '
    options+="\"headerLines\": ${args[--headerLines]}"
fi
if [[ ${args[--ignoreLines]} ]]; then
    options+=', '
    options+="\"ignoreLines\": ${args[--ignoreLines]}"
fi
if [[ ${args[--ignoreQuoteCharacter]} ]]; then
    options+=', '
    options+='"processQuotes": false'
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
if [[ ${args[--quoteCharacter]} ]]; then
    options+=', '
    options+="\"quoteCharacter\": \"${args[--quoteCharacter]}\""
fi
if [[ ${args[--skipBlankRows]} ]]; then
    options+=', '
    options+='"storeBlankRows": false'
fi
if [[ ${args[--skipDataLines]} ]]; then
    options+=', '
    options+="\"skipDataLines\": ${args[--skipDataLines]}"
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
