# get CSRF token (introduced in OpenRefine 3.3)
# shellcheck shell=bash
function get_csrf() {
  local response
  if ! response="$(curl -fs "${OPENREFINE_URL}/command/core/get-csrf-token")"; then
    if ! response="$(curl -fs "${OPENREFINE_URL}/command/core/get-version")"; then
      error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
      exit 1
    fi
  else
    if ! [[ "${response}" == '{"token":"'* ]]; then
      error "getting CSRF token failed!"
      exit 1
    fi
    echo "?csrf_token=$(echo "$response" | cut -d \" -f 4)"
  fi
}
