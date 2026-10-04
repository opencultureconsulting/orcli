# get CSRF token (introduced in OpenRefine 3.3)
# shellcheck shell=bash
function get_csrf() {
  local response
  if ! response="$(curl -fs "${OPENREFINE_URL}/command/core/get-csrf-token")"; then
    error "no OpenRefine reachable/running at ${OPENREFINE_URL}"
  fi
  if ! [[ "${response}" == '{"token":"'* ]]; then
    error "getting CSRF token failed!"
  fi
  response="${response#'{"token":"'}"
  echo "?csrf_token=${response%%\"*}"
}
