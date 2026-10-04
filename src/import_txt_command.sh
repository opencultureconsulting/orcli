# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# set format specific options (shared options are added by post_import)
if [[ ${args[--columnWidths]} ]]; then
    # fixed-width: validate column widths (numbers separated by comma, whitespace allowed)
    columnWidths="${args[--columnWidths]//[[:space:]]/}"
    if ! [[ ${columnWidths} =~ ^[0-9]+(,[0-9]+)*$ ]]; then
        error "invalid --columnWidths ${args[--columnWidths]} (numbers separated by comma expected)!"
    fi
    format="text/line-based/fixed-width"
    option columnWidths "[ ${columnWidths} ]"
else
    format="text/line-based"
    option linesPerRow "${args[--linesPerRow]}"
fi

# call post_import function to post data and validate results
post_import "format=${format}"
