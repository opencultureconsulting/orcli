# shellcheck shell=bash
projectid="$(get_id "${args[project]}")"
separator='\t'

# assemble specific post data (some options require json format)
data+=("project=${projectid}")
data+=("format=tsv")
options='{ '
options+="\"separator\": \"${separator}\""
if [[ ${args[--encoding]} ]]; then
    options+=', '
    options+="\"encoding\": \"${args[--encoding]}\""
fi
options+=' }'
data+=("options=${options}")

# post
mapfile -t curloptions < <(for d in "${data[@]}"; do
    echo "--data"
    echo "$d"
done)
if [[ ${args[--output]} ]]; then
    if ! mkdir -p "$(dirname "${args[--output]}")"; then
        error "unable to create parent directory for ${args[--output]}"
    fi
    curloptions+=("--output")
    curloptions+=("${args[--output]}")
fi
if ! curl -fs "${curloptions[@]}" "${OPENREFINE_URL}/command/core/export-rows"; then
    error "export of ${args[project]} failed!"
else
    if [[ ${args[--output]} ]]; then
        log "export of ${args[project]} successful" "file:${args[--output]}" "rows:$(cat "${args[--output]}" | wc -l )"
    fi
fi
