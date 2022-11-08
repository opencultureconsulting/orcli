# shellcheck shell=bash disable=SC2154 disable=SC2155

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

# support multiple files
for i in "${!files[@]}"; do
    # read each operation into one line
    mapfile -t jsonlines < <(jq -c '.[]' "${files[$i]}")
    for line in "${jsonlines[@]}"; do
        # parse one line/operation into array
        declare -A data="($(echo "$line" | jq -r 'to_entries | map("[\(.key)]=" + @sh "\(.value|tostring)") | .[]'))"
        # map operation names to command endpoints
        com="${data[op]#core/}"
        if [[ $com == "row-reorder" ]]; then com="reorder-rows"; fi
        unset "data[op]"
        # rename engineConfig to engine
        data[engine]="${data[engineConfig]}"
        unset "data[engineConfig]"
        # drop description
        unset "data[description]"
        # prepare curl options
        mapfile -t curloptions < <(for K in "${!data[@]}"; do
            echo "--data"
            echo "$K=${data[$K]}"
        done)
        # get project id and csrf token; post data to it's individual endpoint
        if response="$(curl -fs --data "project=$(get_id "${args[project]}")" "${curloptions[@]}" "${OPENREFINE_URL}/command/core/${com}$(get_csrf)")"; then
            log "applied ${com} to ${args[project]}" "Response: $(jq '.historyEntry.description' <<< "$response")"
        else
            error "applying ${com} from ${files[$i]} to ${args[project]} failed!"
        fi
        unset data
    done
done
