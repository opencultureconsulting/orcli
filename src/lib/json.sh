# encode values as json to build options safely (quotes, backslashes etc.)
# shellcheck shell=bash
function json_string() {
  jq -n --arg s "$1" '$s'
}

# convert a comma separated list into a json array of strings
function json_array() {
  jq -cn --arg s "$1" '$s | split(",")'
}
