# get project id (derived from project name if needed)
# shellcheck shell=bash disable=SC2154
function get_id() {
  local response
  local projects
  local ids
  if ! response="$(curl -fs --get "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
    exit 1
  fi
  if ! projects="$(echo "$response" | jq -r '.projects | keys[] as $k | "\($k):\(.[$k] | .name)"' | grep "${args[project]}")"; then
    error "project ${args[project]} not found"
    exit 1
  fi
  ids=$(echo "$projects" | cut -d : -f 1)
  if ! [[ "${#ids}" == 13 ]]; then
    error "multiple projects found"
    echo >&2 "$projects"
    exit 1
  fi
  echo "$ids"
}
