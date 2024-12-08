# post to export-rows endpoint
# shellcheck shell=bash disable=SC2154
function post_export() {
    local curloptions
    for d in "$@"; do
        curloptions+=("--data-urlencode")
        curloptions+=("$d")
    done
    # support filtering result sets with facets
    if [[ ${args[--mode]} == "records" ]]; then
        mode="record-based"
    else
        mode="row-based"
    fi
    curloptions+=("--data-urlencode")
    curloptions+=("engine={\"facets\":${args[--facets]},\"mode\":\"${mode}\"}")
    # support file output
    if [[ ${args[--output]} ]]; then
        if ! mkdir -p "$(dirname "${args[--output]}")"; then
            error "unable to create parent directory for ${args[--output]}"
        fi
        curloptions+=("--output" "${args[--output]}")
    fi
    # post
    if ! curl -fs "${curloptions[@]}" "${OPENREFINE_URL}/command/core/export-rows$(get_csrf)"; then
        error "exporting ${args[project]} failed!"
    else
        if [[ ${args[--output]} ]]; then
            log "exported ${args[project]}" "file: ${args[--output]}" "lines: $(wc -l <"${args[--output]}")"
        fi
    fi
}
