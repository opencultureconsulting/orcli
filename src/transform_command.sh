# shellcheck shell=bash disable=SC2154 disable=SC2155

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# check existence of files and stdin
for i in "${!files[@]}"; do
    if [[ "${files[$i]}" == '-' ]]; then
        # exit if stdin is selected but not present
        require_stdin
    elif [[ ${files[$i]} != "http://"* ]] && [[ ${files[$i]} != "https://"* ]] && ! [[ -f "${files[$i]}" ]]; then
        # exit if file does not exist
        error "cannot open ${files[$i]} (no such file)!"
    fi
done

# get project id
projectid="$(get_id "${args[project]}")"

# download files if name starts with http:// or https://
fetch_files

# number of history entries (to check whether an operation was applied, because
# OpenRefine before 3.9 silently ignores unknown and invalid operations)
function history_length() {
    if ! curl -fs --get --data "project=${projectid}" "${OPENREFINE_URL}/command/core/get-history" | jq '.past | length'; then
        error "getting history of ${args[project]} failed!"
    fi
}
history_count="$(history_length)"

# support multiple files
for i in "${!files[@]}"; do
    # read each operation into one line
    if json="$(jq -c '.[]' "${files[$i]}")"; then
        mapfile -t jsonlines <<<"$json"
    else
        error "parsing ${files[$i]} failed!"
    fi
    for line in "${jsonlines[@]}"; do
        if ! op="$(jq -er '.op' <<<"$line")"; then
            error "parsing ${files[$i]} failed!"
        fi
        # keep compatibility with hand-written operations that were accepted by the
        # operation-specific endpoints before (op without core/ prefix, default onError)
        line="$(jq -c '
            if (.op | contains("/") | not) then .op = "core/" + .op else . end
            | if (.op | IN("core/text-transform", "core/column-addition", "core/column-addition-by-fetching-urls"))
                and (has("onError") | not) then .onError = "keep-original" else . end
        ' <<<"$line")"
        op="${op#core/}"
        # post each operation separately to apply-operations for logging per operation
        if ! post_command apply-operations "project=${projectid}" "operations=[${line}]" && [[ $response_code != "pending" ]]; then
            error "transforming ${args[project]} with ${op} from ${files[$i]} failed!" "Response: ${response_message}"
        fi
        if [[ $response_code == "pending" ]]; then
            # long-running operations (e.g. fetching URLs, reconciling) are processed asynchronously
            log "transforming ${args[project]} with ${op} (waiting for long-running process)..."
            while true; do
                if ! processes="$(curl -fs --get --data "project=${projectid}" "${OPENREFINE_URL}/command/core/get-processes")"; then
                    error "transforming ${args[project]} with ${op} from ${files[$i]} failed!"
                fi
                if [[ $(jq '.processes | length' <<<"$processes") == 0 ]]; then
                    break
                fi
                sleep 1
            done
            if [[ $(jq '.exceptions | length' <<<"$processes") != 0 ]]; then
                error "transforming ${args[project]} with ${op} from ${files[$i]} failed!" "Response: $(jq -r '[.exceptions[].message] | join("; ")' <<<"$processes")"
            fi
        fi
        if [[ $response_code == "ok" ]] && jq -e 'has("historyEntries")' <<<"$response" >/dev/null; then
            # OpenRefine 3.10+ responds with the new history entries
            history_count=$((history_count + $(jq '.historyEntries | length' <<<"$response")))
            log "transformed ${args[project]} with ${op}" "Response: $(jq -r '.historyEntries[].description' <<<"$response")"
        else
            # long-running operations and OpenRefine before 3.10 respond without history entries
            new_history_count="$(history_length)"
            if [[ ${new_history_count} == "${history_count}" ]]; then
                error "transforming ${args[project]} with ${op} from ${files[$i]} failed!" "Response: operation was not applied (unknown operation or invalid parameters?)"
            fi
            history_count="${new_history_count}"
            log "transformed ${args[project]} with ${op}" "Response: $(curl -fs --get --data "project=${projectid}" "${OPENREFINE_URL}/command/core/get-history" | jq -r '.past[-1].description')"
        fi
    done
done
