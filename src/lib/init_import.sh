# common import tasks to support multiple files and URLs
# shellcheck shell=bash
function init_import() {
    local files file tmpdir
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
    # read pipes if name starts with /dev/fd
    for i in "${!files[@]}"; do
        if [[ ${files[$i]} == "/dev/fd"* ]]; then
            if ! cat "${files[$i]}" >"${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"; then
                error "reading of ${files[$i]} failed!"
            fi
            files[$i]="${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"
        fi
    done
    # create a zip archive if there are multiple files
    if [[ ${#files[@]} -gt 1 ]]; then
        file="$tmpdir/Untitled.zip"
        if ! zip --quiet --must-match "$file" "${files[@]}"; then
            error "creating zip archive with ${files[*]} failed!"
        fi
    else
        file="${files[0]}"
    fi
    # basic post data
    if [[ ${file} == "-" ]]; then
        data+=("project-file=@-")
    else
        if ! path=$(readlink -e "${file}"); then
            error "file ${file} not found!"
        fi
        data+=("project-file=@${path}")
    fi
    if [[ ${args[--projectName]} ]]; then
        data+=("project-name=${args[--projectName]}")
    else
        if [[ ${file} == "-" ]]; then
            name="Untitled"
        else
            name="$(basename "${path}" | tr '.' ' ')"
        fi
        data+=("project-name=${name}")
    fi
}
