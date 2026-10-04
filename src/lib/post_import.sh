# post to create-project endpoint and validate
# shellcheck shell=bash disable=SC2154
function post_import() {
    local curloptions projectid projectname rows
    # add options of flags shared by import commands
    import_options
    for d in "$@" "options={ ${options} }"; do
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
    # declare the encoding of the uploaded file in the request, because OpenRefine before 3.8
    # prefers its guessed encoding over the encoding option
    if [[ ${args[--encoding]} ]]; then
        curloptions+=("--header" "Content-Type: multipart/form-data; charset=${args[--encoding]}")
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
    projectname=$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-project-metadata" | jq -r '.name')
    rows=$(curl -fs --get --data project="$projectid" --data limit=0 --data start=0 "${OPENREFINE_URL}/command/core/get-rows")
    rows="${rows#*\"total\":}"
    rows="${rows%%[,\}]*}"
    if [[ "$rows" = "0" ]]; then
        error "import of ${args[file]} contains 0 rows!"
    else
        log "imported ${args[file]}" "${redirect_url}" "name: ${projectname}" "rows: ${rows}"
    fi
    # json / jsonl --rename: remove record path fragments from column names with
    # one request (first line: rename operations, second line: expected columns)
    if [[ ${args[--rename]} ]]; then
        if ! renaming="$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq -c '[ .[].name ] | ([ .[] | select(startswith("_ - ")) | { op: "core/column-rename", description: ("Rename column " + .), oldColumnName: ., newColumnName: ltrimstr("_ - ") } ]), map(ltrimstr("_ - "))')"; then
            error "renaming columns in ${projectname} failed!"
        fi
        if [[ ${renaming%%$'\n'*} != "[]" ]]; then
            if ! post_command apply-operations "project=${projectid}" "operations=${renaming%%$'\n'*}"; then
                error "renaming columns in ${projectname} failed!" "Response: ${response_message}"
            fi
            # OpenRefine before 3.9 silently skips invalid operations
            if [[ $(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-columns-info" | jq -c '[ .[].name ]') != "${renaming#*$'\n'}" ]]; then
                error "renaming columns in ${projectname} failed!" "Response: unexpected column names after renaming (duplicate names?)"
            fi
        fi
        log "renamed columns in ${projectname}"
    fi
}
