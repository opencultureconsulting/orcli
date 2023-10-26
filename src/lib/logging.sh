# print messages to STDERR
# shellcheck shell=bash
function error() {
  echo >&2 "[$(date +'%Y-%m-%dT%H:%M:%S')] ERROR: $1"
  shift
  for msg in "$@"; do echo >&2 "  $msg"; done
  if [[ -f "$OPENREFINE_TMPDIR/openrefine.log" ]]; then
    echo >&2 "last 50 lines of OpenRefine's server log:"
    echo >&2 "-----------------------------------------"
    tail >&2 -50 "$OPENREFINE_TMPDIR/openrefine.log"
    echo >&2 "-----------------------------------------"
  fi
  exit 1
}
function log() {
  if ! [[ ${args[--quiet]} || $ORCLI_QUIET ]]; then
    echo >&2 "[$(date +'%Y-%m-%dT%H:%M:%S')] $1"
    shift
    for msg in "$@"; do echo >&2 "  $msg"; done
  fi
}
