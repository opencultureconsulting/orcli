# shellcheck shell=bash disable=SC2154

# get project id
projectid="$(get_id "${args[project]}")"

if ! response="$(curl -fs --get --data "project=${projectid}" "${OPENREFINE_URL}/command/core/get-project-metadata")"; then
    error "reading metadata of ${args[project]} failed!"
else
    columns="$(curl -fs --get --data "project=${projectid}" "${OPENREFINE_URL}/command/core/get-models" | jq '[ .columnModel | .columns[] | .name ]')"
    jq "{ id: ${projectid} } + . + {columns: $columns }" <<<"$response"
fi
