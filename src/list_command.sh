# get all project metadata and reshape json to print a list
# shellcheck shell=bash
if ! response="$(curl -fs --get "${OPENREFINE_URL}/command/core/get-all-project-metadata")"; then
  error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
else
  if [[ "${response}" == '{"projects":{}}' ]]; then
    log "${OPENREFINE_URL} does not contain any projects yet."
  else
    echo "$response" | jq -r '.projects | keys[] as $k | "\($k):\(.[$k] | .name)"'
  fi
fi
