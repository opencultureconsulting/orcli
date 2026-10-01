# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# exit if stdin is selected but not present
if [[ ${file} == '-' ]]; then
    if ! read -u 0 -t 0; then
        sleep 1
        if ! read -u 0 -t 0; then
            orcli_import_txt_usage
            exit 1
        fi
    fi
fi

# validate column widths (numbers separated by comma, whitespace allowed)
columnWidths="${args[--columnWidths]//[[:space:]]/}"
if [[ -n ${columnWidths} ]] && ! [[ ${columnWidths} =~ ^[0-9]+(,[0-9]+)*$ ]]; then
    error "invalid --columnWidths ${args[--columnWidths]} (numbers separated by comma expected)!"
fi

# assemble specific post data (some options require json format)
data+=("format=text/line-based/fixed-width")
options='{ '
options+="\"columnWidths\": [ ${columnWidths} ]"
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
