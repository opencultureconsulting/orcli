# log error message to STDERR
function error {
  echo >&2 "[$(date +'%Y-%m-%dT%H:%M:%S')]: ERROR $*"
}
