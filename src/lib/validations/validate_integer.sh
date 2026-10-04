# shellcheck shell=bash
validate_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]] || echo "must be an integer"
}

validate_positive_integer() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]] || echo "must be a positive integer"
}
