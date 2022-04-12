# get project id (derived from project name if needed)
# shellcheck shell=bash disable=SC2154
function get_id() {
  local response
  local projects
  local ids
  if ! response="$(curl -fs --get "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
  fi
  if ! projects="$(echo "$response" | jq -r '.projects | keys[] as $k | "\($k):\(.[$k] | .name)"' | grep ":${args[project]}$")"; then
    error "project ${args[project]} not found"
  fi
  ids=$(echo "$projects" | cut -d : -f 1)
  if ! [[ "${#ids}" == 13 ]]; then
    error "multiple projects found" "$projects"
  fi
  echo "$ids"
}
