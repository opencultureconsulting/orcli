# post to create-project endpoint and validate
# shellcheck shell=bash disable=SC2154
function post_import() {
    local curloptions
    local projectid
    local projectname
    local rows
    # post
    mapfile -t curloptions < <(for d in "$@"; do
        echo "--form"
        echo "$d"
    done)
    if ! redirect_url="$(curl -fs --write-out "%{redirect_url}\n" "${curloptions[@]}" "${OPENREFINE_URL}/command/core/create-project-from-upload$(get_csrf)")"; then
        error "import of ${args[file]} failed!"
    fi
    # validate
    projectid=$(cut -d '=' -f 2 <<<"$redirect_url")
    if [[ ${#projectid} != 13 ]]; then
        error "import of ${args[file]} failed!"
    fi
    projectname=$(curl -fs --get --data project="$projectid" "${OPENREFINE_URL}/command/core/get-project-metadata" | tr "," "\n" | grep name | cut -d ":" -f 2)
    projectname="${projectname:1:${#projectname}-2}"
    rows=$(curl -fs --get --data project="$projectid" --data limit=0 "${OPENREFINE_URL}/command/core/get-rows" | tr "," "\n" | grep total | cut -d ":" -f 2)
    if [[ "$rows" = "0" ]]; then
        error "import of ${args[file]} contains 0 rows!" "${redirect_url}" "name:${projectname}" "rows:${rows}"
    else
        log "import of ${args[file]} successful" "${redirect_url}" "name:${projectname}" "rows:${rows}"
    fi
}
