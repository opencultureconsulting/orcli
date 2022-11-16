# shellcheck shell=bash disable=SC2154
# get project id
projectid="$(get_id "${args[project]}")"
echo "$projectid"