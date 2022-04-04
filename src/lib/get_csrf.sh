# get CSRF token (introduced in OpenRefine 3.3)
# shellcheck shell=bash
function get_csrf() {
  if [[ "${OPENREFINE_CSRF}" == true ]]; then
    local response
    response=$(curl -fs "${OPENREFINE_URL}/command/core/get-csrf-token")
    if ! [[ "${response}" == '{"token":"'* ]]; then
      error "getting CSRF token failed!"
      exit 1
    fi
    echo "?csrf_token=$(echo "$response" | cut -d \" -f 4)"
  fi
}
