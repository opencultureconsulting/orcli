# exit with usage of the current command if stdin is selected but not present
# shellcheck shell=bash disable=SC2154
function require_stdin() {
  if ! read -u 0 -t 0; then
    sleep 1
    if ! read -u 0 -t 0; then
      "orcli_${action// /_}_usage"
      exit 1
    fi
  fi
}
