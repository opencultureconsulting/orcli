# shellcheck shell=bash disable=SC2154

# call init_import function to eval args and to set basic post data
init_import

# set format specific options (shared options are added by post_import)
option recordPath "${args[--recordPath]}"

# call post_import function to post data and validate results
post_import "format=text/json"
