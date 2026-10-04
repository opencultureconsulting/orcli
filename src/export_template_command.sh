# shellcheck shell=bash disable=SC2154 disable=SC2155

# get project id
projectid="$(get_id "${args[project]}")"

# download file if name starts with http:// or https://
files=("${args[file]}")
fetch_files
args[file]="${files[0]}"

# check existence of file or stdin
if [[ "${args[file]}" == '-' ]]; then
    # exit if stdin is selected but not present
    require_stdin
elif ! [[ -f "${args[file]}" ]]; then
    # exit if file does not exist
    error "cannot open ${args[file]} (no such file)!"
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
