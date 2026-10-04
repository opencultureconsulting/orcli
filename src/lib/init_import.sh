# common import tasks to support multiple files and URLs
# shellcheck shell=bash disable=SC2154
function init_import() {
    # catch args, convert the space delimited string to an array
    files=()
    eval "files=(${args[file]})"
    # download files if name starts with http:// or https://
    fetch_files
    # read pipes if name starts with /dev/fd
    for i in "${!files[@]}"; do
        if [[ ${files[$i]} == "/dev/fd"* ]]; then
            init_tmpdir
            if ! cat "${files[$i]}" >"${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"; then
                error "reading of ${files[$i]} failed!"
            fi
            files[i]="${tmpdir}/${files[$i]//[^A-Za-z0-9._-]/_}"
        fi
    done
    # create a zip archive if there are multiple files
    if [[ ${#files[@]} -gt 1 ]]; then
        init_tmpdir
        file="$tmpdir/Untitled.zip"
        if ! zip --quiet --must-match "$file" "${files[@]}"; then
            error "creating zip archive with ${files[*]} failed!"
        fi
    else
        file="${files[0]}"
    fi
    # exit if stdin is selected but not present
    if [[ ${file} == '-' ]]; then
        require_stdin
    fi
}
