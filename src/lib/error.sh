# log error message to STDERR
# shellcheck shell=bash
function error() {
  echo >&2 "[$(date +'%Y-%m-%dT%H:%M:%S')]: ERROR $*"
}
