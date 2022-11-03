# shellcheck shell=bash disable=SC2154
#get_id "${args[project]}"

# check if stdin is present if selected
if [[ ${args[file]} == '-' ]] || [[ ${args[file]} == '"-"' ]]; then
    if ! read -u 0 -t 0; then
        orcli_transform_usage
        exit 1
    fi
fi
# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"
# create tmp directory
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' 0 2 3 15
# download files if name starts with http:// or https://
for i in "${!files[@]}"; do
    if [[ ${files[$i]} == "http://"* ]] || [[ ${files[$i]} == "https://"* ]]; then
        if ! curl -fs --location "${files[$i]}" >"${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"; then
            error "download of ${files[$i]} failed!"
        fi
        files[$i]="${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"
    fi
done

# support multiple files and stdin
readarray -t jsonlines < <(cat "${files[@]}" | jq --slurp --compact-output 'add | .[]')
for line in "${jsonlines[@]}"; do
  declare -A data="($(echo "$line" | jq -r 'to_entries | map("[\(.key)]=" + @sh "\(.value|tostring)") | .[]'))"
  echo "${data[op]#core/}"
  unset "data[op]"
  unset "data[description]"
  for K in "${!data[@]}"; do echo "$K" --- "${data[$K]}"; done
  unset data
done