# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# set format specific options (shared options are added by post_import)
option separator "$(json_string "${args[--separator]}")"
# OpenRefine 3.8 to 3.10.1 still parse quotes without processQuotes, so also
# set NUL as quote character to treat quotes as normal characters
# https://github.com/OpenRefine/OpenRefine/issues/7042
if [[ ${args[--ignoreQuoteCharacter]} ]]; then
    option quoteCharacter '"\u0000"'
fi

# call post_import function to post data and validate results
post_import "format=text/line-based/*sv"
