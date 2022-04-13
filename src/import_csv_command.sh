# shellcheck shell=bash

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"
if [ "${files[*]}" = "-" ] && [ -t 0 ]; then
    printf "missing required argument or standard input\nusage: cli FILE...\n"
    exit 1
fi

# TODO: support URLs
# TODO: zip files if more than 1
file="${files[*]}"

# prepare input
data=()
data+=("--form" "format=text/line-based/*sv")
if [[ ${file} == "-" ]]; then
    data+=("--form" "project-file=@-")
else
    if ! path=$(readlink -e "${file}"); then
        error "file ${file} not found!"
    fi
    data+=("--form" "project-file=@${path}")
fi
if [[ ${args[--projectName]} ]]; then
    data+=("--form" "project-name=${args[--projectName]}")
else
    name="$(basename "${path}" | tr '.' ' ')"
    data+=("--form" "project-name=${name}")
fi
options='{ '
options+="\"separator\": \"${args[--separator]}\""
if [[ ${args[--encoding]} ]]; then
    options+=", \"encoding\": \"${args[--encoding]}\""
fi
if [[ ${args[--trimStrings]} ]]; then
    options+=", \"trimStrings\": true"
fi
options+=' }'

# execute curl
if ! redirect_url="$(curl -fs --write-out "%{redirect_url}\n" "${data[@]}" --form options="${options}" "${OPENREFINE_URL}/command/core/create-project-from-upload$(get_csrf)")"; then
    error "import of ${files[*]} failed!"
fi

# validate import
projectid=$(cut -d '=' -f 2 <<< "$redirect_url")
if [[ ${#projectid} != 13 ]]; then
    error "import of ${files[*]} failed!"
fi
rows=$(curl -fs --get --data project="$projectid" --data limit=0 "${OPENREFINE_URL}/command/core/get-rows" | tr "," "\n" | grep total | cut -d ":" -f 2)
if [[ "$rows" = "0" ]]; then
    error "import of ${files[*]} contains 0 rows!" "${redirect_url}" "name:${name}" "rows:${rows}"
else
    log "import of ${files[*]} successful" "${redirect_url}" "name:${name}" "rows:${rows}"
fi