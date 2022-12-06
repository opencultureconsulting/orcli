# shellcheck shell=bash disable=SC2154

# get project ids
projectids="$(get_ids "${args[project]}")"

# loop over multiple project ids
for projectid in ${projectids}; do
    # get csrf token and post data
    if response="$(curl -fs --data "project=${projectid}" "${OPENREFINE_URL}/command/core/delete-project$(get_csrf)")"; then
        response_code="$(jq -r '.code' <<<"$response")"
        if [[ $response_code == "ok" ]]; then
            log "deleted ${args[project]} (${projectid})"
        else
            error "deleting ${args[project]} failed!"
        fi
    else
        error "deleting ${args[project]} failed!"
    fi
done
