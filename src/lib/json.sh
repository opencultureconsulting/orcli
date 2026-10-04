# encode values as json to build options safely (quotes, backslashes etc.)
# in pure bash for speed, with jq only for rare control characters
# shellcheck shell=bash
function json_string() {
  local s="${1//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  if [[ $s == *[[:cntrl:]]* ]]; then
    jq -n --arg s "$1" '$s'
  else
    echo "\"${s}\""
  fi
}

# convert a comma separated list into a json array of strings
function json_array() {
  local s="$1," a=""
  while [[ $s ]]; do
    a+="${a:+,}$(json_string "${s%%,*}")"
    s="${s#*,}"
  done
  echo "[${a}]"
}

# quote a string literal for GREL expressions (escape backslashes and quotes)
function grel_string() {
  local s="${1//\\/\\\\}"
  echo "\"${s//\"/\\\"}\""
}

# quote a regular expression literal for GREL expressions (escape unescaped slashes)
function grel_regex() {
  local s="$1" r="" c i escaped=""
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    if [[ $escaped ]]; then
      escaped=""
    elif [[ $c == "\\" ]]; then
      escaped=1
    elif [[ $c == '/' ]]; then
      c='\/'
    fi
    r+="$c"
  done
  echo "/${r}/"
}
