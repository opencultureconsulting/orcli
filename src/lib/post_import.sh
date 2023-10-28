# post to create-project endpoint and validate
# shellcheck shell=bash disable=SC2154
function post_import() {
    local curloptions projectid projectname rows
    for d in "$@"; do
        curloptions+=("--form-string")
        curloptions+=("$d")
    done
    # basic post data
    if [[ ${file} == "-" ]]; then
        curloptions+=("--form" "project-file=@-")
    else
        if ! path=$(readlink -e "${file}"); then
            error "cannot open ${file} (no such file)!"
        fi
        curloptions+=("--form" "project-file=@${path}")
    fi
    if [[ ${args[--projectName]} ]]; then
        curloptions+=("--form-string" "project-name=${args[--projectName]}")
    else
        if [[ ${file} == "-" ]]; then
            name="Untitled"
        else
            name="$(basename "${path}" | tr '.' ' ')"
        fi
        curloptions+=("--form-string" "project-name=${name}")
    fi
    # post
    if ! redirect_url="$(curl -fs --write-out "%{redirect_url}\n" "${curloptions[@]}" "${OPENREFINE_URL}/command/core/create-project-from-upload$(get_csrf)")"; then
        error "importing ${args[file]} failed!"
    fi
    # validate
    projectid=$(cut -d '=' -f 2 <<<"$redirect_url")
    if [[ ${#projectid} != 13 ]]; then
        error "importing ${args[file]} failed!"
    fi
    projectname=$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-project-metadata" | tr "," "\n" | grep name | cut -d ":" -f 2)
    projectname="${projectname:1:${#projectname}-2}"
    rows=$(curl -fs --get --data project="$projectid" --data limit=0 "${OPENREFINE_URL}/command/core/get-rows" | tr "," "\n" | grep total | cut -d ":" -f 2)
    if [[ "$rows" = "0" ]]; then
        error "import of ${args[file]} contains 0 rows!"
    else
        log "imported ${args[file]}" "${redirect_url}" "name: ${projectname}" "rows: ${rows}"
    fi
    # json / jsonl --rename
    if [[ ${args[--rename]} ]]; then
        csrf="$(get_csrf)"
        readarray -t columns < <(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq -r '.[].name')
        for c in "${columns[@]}"; do
            if ! curl -fs -o /dev/null --data project="$projectid" --data "oldColumnName=${c}" --data "newColumnName=${c##_ - }" "${OPENREFINE_URL}/command/core/rename-column${csrf}"; then
                error "renaming columns in ${projectname} failed!"
            fi
        done
        log "renamed columns in ${projectname}"
    fi
}
