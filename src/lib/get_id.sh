# get project id (derived from project name if needed)
# shellcheck shell=bash
function get_id() {
  local response projects projectid
  if ! response="$(curl -fs "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
  fi
  # exact match on project id or name (as id:name lines)
  if ! projects="$(jq -er --arg p "$1" '.projects | to_entries[] | select(.key == $p or .value.name == $p) | "\(.key):\(.value.name)"' <<<"$response")"; then
    error "project $1 not found"
  fi
  if [[ $2 != "all" && $projects == *$'\n'* ]]; then
    error "multiple projects found" "$projects"
  fi
  while IFS=: read -r projectid _; do
    echo "$projectid"
  done <<<"$projects"
}

# get ids of all projects with the same name
function get_ids() {
  get_id "$1" all
}
