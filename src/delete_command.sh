# shellcheck shell=bash disable=SC2154

# get project id(s)
if [[ ${args[--force]} ]]; then
    projectids="$(get_ids "${args[project]}")"
else
    projectids="$(get_id "${args[project]}")"
fi

# loop over one or more project ids
for projectid in ${projectids}; do
    if post_command delete-project "project=${projectid}"; then
        log "deleted ${args[project]} (${projectid})"
    else
        error "deleting ${args[project]} failed!" "Response: ${response_message}"
    fi
done
