# shellcheck shell=bash disable=SC2154

# check if stdin is present if selected
if [[ ${args[file]} == '-' ]] || [[ ${args[file]} == '"-"' ]] && [ -t 0 ]; then
    orcli_batch_usage
    exit 1
fi

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# update OPENREFINE_URL env
OPENREFINE_URL="http://localhost:${args[--port]}"

# locate orcli and OpenRefine
if command -v orcli &>/dev/null; then
    orcli="orcli"
elif [[ -x "orcli" ]]; then
    orcli="./orcli"
else
    error "orcli is not executable!" "Try: chmod + ./orcli"
fi
if [[ -x "refine" ]]; then
    openrefine="./refine"
else
    error "OpenRefine's startup script (refine) not found!" "Did you put orcli in your OpenRefine app dir?"
fi

# create tmp directory
tmpdir="$(mktemp -d)"
trap '{ rm -rf "$tmpdir"; }' 0 2 3 15

# check if OpenRefine is already running
if curl -fs "${OPENREFINE_URL}" &>/dev/null; then
    error "OpenRefine is already running on port ${args[--port]}." "Hint: Stop the other process or use another port."
fi

# start OpenRefine with tmp workspace and autosave period 25 hours
REFINE_AUTOSAVE_PERIOD=1440 $openrefine -d "$tmpdir" -m "${args[--memory]}" -p "${args[--port]}" -x refine.headless=true -v warn &>"$tmpdir/openrefine.log" &
openrefine_pid="$!"

# update trap to kill OpenRefine on error or exit
trap '{ rm -rf "$tmpdir"; kill -9 "$openrefine_pid"; }' 0 2 3 15

# wait until OpenRefine is running (timeout 20s)
if ! curl -fs --retry 20 --retry-connrefused --retry-delay 1 "${OPENREFINE_URL}/command/core/get-version" &>/dev/null; then
    error "starting OpenRefine server failed!"
else
    log "started OpenRefine" "port: ${args[--port]}" "memory: ${args[--memory]}" "tmpdir: ${tmpdir}" "pid: ${openrefine_pid}"
fi

# execute shell script
export orcli tmpdir OPENREFINE_URL openrefine_pid
bash -e <(awk 1 "${files[@]}")
