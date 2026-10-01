# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# exit if stdin is selected but not present
if [[ ${file} == '-' ]]; then
    if ! read -u 0 -t 0; then
        sleep 1
        if ! read -u 0 -t 0; then
            orcli_import_csv_usage
            exit 1
        fi
    fi
fi

# assemble specific post data (some options require json format)
data+=("format=text/line-based/*sv")
options='{ '
options+="\"separator\": $(json_string "${args[--separator]}")"
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": $(json_string "${args[--encoding]}")"
fi
if [[ ${args[--blankCellsAsStrings]} ]]; then
    options+=', '
    options+='"storeBlankCellsAsNulls": false'
fi
if [[ ${args[--columnNames]} ]]; then
    options+=', '
    options+="\"columnNames\": $(json_array "${args[--columnNames]}")"
fi
if [[ ${args[--guessCellValueTypes]} ]]; then
    options+=', '
    options+='"guessCellValueTypes": true'
fi
if [[ ${args[--headerLines]} ]]; then
    options+=', '
    options+="\"headerLines\": ${args[--headerLines]}"
fi
# importer applies ignoreLines after inserting the column names,
# so skip the ignored lines as data lines instead
skipDataLines="${args[--skipDataLines]}"
if [[ ${args[--columnNames]} ]] && ((args[--ignoreLines] > 0)); then
    skipDataLines=$((skipDataLines + args[--ignoreLines]))
elif [[ ${args[--ignoreLines]} ]]; then
    options+=', '
    options+="\"ignoreLines\": ${args[--ignoreLines]}"
fi
if [[ ${args[--ignoreQuoteCharacter]} ]]; then
    options+=', '
    options+='"processQuotes": false'
fi
if [[ ${args[--includeFileSources]} ]]; then
    options+=', '
    options+='"includeFileSources": true'
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
    options+="\"quoteCharacter\": $(json_string "${args[--quoteCharacter]}")"
fi
if [[ ${args[--skipBlankRows]} ]]; then
    options+=', '
    options+='"storeBlankRows": false'
fi
if [[ ${skipDataLines} ]]; then
    options+=', '
    options+="\"skipDataLines\": ${skipDataLines}"
fi
if [[ ${args[--projectName]} ]]; then
    options+=', '
    options+="\"projectName\": $(json_string "${args[--projectName]}")"
fi
if [[ ${args[--projectTags]} ]]; then
    options+=', '
    options+="\"projectTags\": $(json_array "${args[--projectTags]}")"
fi
if [[ ${args[--trimStrings]} ]]; then
    options+=', '
    options+='"trimStrings": true'
fi
options+=' }'
data+=("options=${options}")

# call post_import function to post data and validate results
post_import "${data[@]}"
