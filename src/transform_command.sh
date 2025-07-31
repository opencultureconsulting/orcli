# shellcheck shell=bash disable=SC2154 disable=SC2155

# exit if stdin is selected but not present
if [[ ${args[file]} == '-' ]] || [[ ${args[file]} == '"-"' ]]; then
    if ! read -u 0 -t 0; then
        sleep 1
        if ! read -u 0 -t 0; then
            orcli_transform_usage
            exit 1
        fi
    fi
fi

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# get project id
projectid="$(get_id "${args[project]}")"

# create tmp directory
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' 0 2 3 15

# download files if name starts with http:// or https://
for i in "${!files[@]}"; do
    if [[ ${files[$i]} == "http://"* ]] || [[ ${files[$i]} == "https://"* ]]; then
        if ! curl -fs --location "${files[$i]}" >"${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"; then
            error "download of ${files[$i]} failed!"
        fi
        files[i]="${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"
    fi
done

# check existence of files and stdin
for i in "${!files[@]}"; do
    if [[ "${files[$i]}" == '-' ]] || [[ "${files[$i]}" == '"-"' ]]; then
        # exit if stdin is selected but not present
        if ! read -u 0 -t 0; then
            orcli_run_usage
            exit 1
        fi
    else
        # exit if file does not exist
        if ! [[ -f "${files[$i]}" ]]; then
            error "cannot open ${files[$i]} (no such file)!"
        fi
    fi
done

# support multiple files
for i in "${!files[@]}"; do
    # read each operation into one line
    if json="$(jq -c '.[]' "${files[$i]}")"; then
        mapfile -t jsonlines <<<"$json"
    else
        error "parsing ${files[$i]} failed!"
    fi
    for line in "${jsonlines[@]}"; do
        # parse one line/operation into array
        filter='[to_entries[]|"["+(.key|@sh)+"]="+(.value|tostring|@sh)]|"("+join(" ")+")"'
        declare -A array=$(jq --join-output "${filter}" <<< "$line")
        if [[ ! ${array[op]} ]]; then
            error "parsing ${files[$i]} failed!"
        fi
        # map operation names to command endpoints
        # https://github.com/OpenRefine/OpenRefine/blob/master/main/webapp/modules/core/MOD-INF/controller.js
        com="${array[op]#core/}"
        if [[ $com == "multivalued-cell-join" ]]; then com="join-multi-value-cells"; fi
        if [[ $com == "multivalued-cell-split" ]]; then com="split-multi-value-cells"; fi
        if [[ $com == "column-addition" ]]; then com="add-column"; fi
        if [[ $com == "column-addition-by-fetching-urls" ]]; then com="add-column-by-fetching-urls"; fi
        if [[ $com == "column-removal" ]]; then com="remove-column"; fi
        if [[ $com == "column-rename" ]]; then com="rename-column"; fi
        if [[ $com == "column-move" ]]; then com="move-column"; fi
        if [[ $com == "column-split" ]]; then com="split-column"; fi
        if [[ $com == "column-reorder" ]]; then com="reorder-columns"; fi
        if [[ $com == "recon" ]]; then com="reconcile"; fi
        if [[ $com == "extend-reconciled-data" ]]; then com="extend-data"; fi
        if [[ $com == "row-star" ]]; then com="annotate-rows"; fi
        if [[ $com == "row-flag" ]]; then com="annotate-rows"; fi
        if [[ $com == "row-removal" ]]; then com="remove-rows"; fi
        if [[ $com == "row-reorder" ]]; then com="reorder-rows"; fi
        unset "array[op]"
        # rename engineConfig to engine
        array[engine]="${array[engineConfig]}"
        unset "array[engineConfig]"
        # drop description
        unset "array[description]"
        # remove line breaks in expression
        array[expression]="${array[expression]//$'\n'/}"
        # prepare curl options
        mapfile -t curloptions < <(for K in "${!array[@]}"; do
            echo "--data-urlencode"
            echo "$K=${array[$K]}"
        done)
        # get csrf token and post data to it's individual endpoint
        if response="$(curl -fs --data "project=${projectid}" "${curloptions[@]}" "${OPENREFINE_URL}/command/core/${com}$(get_csrf)")"; then
            response_code="$(jq -r '.code' <<<"$response")"
            if [[ $response_code == "ok" ]]; then
                log "transformed ${args[project]} with ${com}" "Response: $(jq -r '.historyEntry.description' <<<"$response")"
            else
                error "transforming ${args[project]} with ${com} from ${files[$i]} failed!" "Response: $(jq -r '.message' <<<"$response")"
            fi
        else
            error "transforming ${args[project]} with ${com} from ${files[$i]} failed!"
        fi
        unset array
    done
done
