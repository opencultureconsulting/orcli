# shellcheck shell=bash disable=SC2154 disable=SC2155

# get project id
projectid="$(get_id "${args[project]}")"

# create tmp directory
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' 0 2 3 15

# download file if name starts with http:// or https://
if [[ ${args[file]} == "http://"* ]] || [[ ${args[file]} == "https://"* ]]; then
    if ! curl -fs --location "${args[file]}" >"${tmpdir}/${args[file]//[^A-Za-z0-9._-]/_}"; then
        error "download of ${args[file]} failed!"
    fi
    args[file]="${tmpdir}/${args[file]//[^A-Za-z0-9._-]/_}"
fi

# check existence of file or stdin
if [[ "${args[file]}" == '-' ]] || [[ "${args[file]}" == '"-"' ]]; then
    # exit if stdin is selected but not present
    if ! read -u 0 -t 0; then
        sleep 1
        if ! read -u 0 -t 0; then
            orcli_export_template_usage
            exit 1
        fi
    fi
else
    # exit if file does not exist
    if ! [[ -f "${args[file]}" ]]; then
        error "cannot open ${args[file]} (no such file)!"
    fi
fi

# read args[file] into variable to remove trailing newline
template=$(cat "${args[file]}")

# assemble specific post data
data+=("project=${projectid}")
data+=("format=template")
data+=("template=${template}")
if [[ ${args[--prefix]} ]]; then
    data+=("prefix=${args[--prefix]}")
fi
if [[ ${args[--suffix]} ]]; then
    data+=("suffix=${args[--suffix]}")
fi
if [[ ${args[--separator]} ]]; then
    data+=("separator=${args[--separator]}")
fi

# call post_export function to post data and validate results
post_export "${data[@]}"
