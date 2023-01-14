# post to export-rows endpoint
# shellcheck shell=bash disable=SC2154
function post_export() {
    local curloptions
    mapfile -t curloptions < <(for d in "$@"; do
        echo "--data"
        echo "$d"
    done)
    # support file output
    if [[ ${args[--output]} ]]; then
        if ! mkdir -p "$(dirname "${args[--output]}")"; then
            error "unable to create parent directory for ${args[--output]}"
        fi
        curloptions+=("--output" "${args[--output]}")
    fi
    # post
    if ! curl -fs "${curloptions[@]}" "${OPENREFINE_URL}/command/core/export-rows"; then
        error "exporting ${args[project]} failed!"
    else
        if [[ ${args[--output]} ]]; then
            log "exported ${args[project]}" "file: ${args[--output]}" "rows: $(wc -l <"${args[--output]}")"
        fi
    fi
}
