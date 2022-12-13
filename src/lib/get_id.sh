# get project id (derived from project name if needed)
# shellcheck shell=bash
function get_id() {
  local response projects projectid
  if ! response="$(curl -fs --get "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
  fi
  if ! projects="$(echo "$response" | jq -r '.projects | keys[] as $k | "\($k):\(.[$k] | .name)"' | grep -e ":$1$" -e "^$1:")"; then
    error "project $1 not found"
  fi
  projectid=$(echo "$projects" | cut -d : -f 1)
  if ! [[ "${#projectid}" == 13 ]]; then
    error "multiple projects found" "$projects"
  fi
  echo "$projectid"
}

function get_ids() {
  local response projects
  if ! response="$(curl -fs --get "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
  fi
  if ! projects="$(echo "$response" | jq -r '.projects | keys[] as $k | "\($k):\(.[$k] | .name)"' | grep -e ":$1$" -e "^$1:")"; then
    error "project $1 not found"
  fi
  echo "$projects" | cut -d : -f 1
}
