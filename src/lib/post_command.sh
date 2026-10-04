# post url-encoded data to an OpenRefine command and check the response code,
# because OpenRefine responds to many errors with HTTP 200 and {"code":"error"}
# sets response, response_code and (on failure) response_message
# returns 0 if the response code is ok
# shellcheck shell=bash
function post_command() {
  local endpoint="$1" d curloptions=()
  shift
  for d in "$@"; do
    curloptions+=("--data-urlencode" "$d")
  done
  response_code="" response_message=""
  if ! response="$(curl -fs "${curloptions[@]}" "${OPENREFINE_URL}/command/core/${endpoint}$(get_csrf)")"; then
    response_message="request to ${endpoint} failed"
    return 1
  fi
  response_code="$(jq -r '.code // empty' <<<"$response" 2>/dev/null)"
  if [[ $response_code != "ok" ]]; then
    response_message="$(jq -r '.message // empty' <<<"$response" 2>/dev/null)"
    response_message="${response_message:-${response}}"
    return 1
  fi
}
