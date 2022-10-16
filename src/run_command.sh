# shellcheck shell=bash disable=SC2154 source=/dev/null

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# check if stdin is present if selected
if ! [[ ${args[--interactive]} ]]; then
    if [[ ${args[file]} == '-' ]] || [[ ${args[file]} == '"-"' ]]; then
        if ! read -u 0 -t 0; then
            orcli_run_usage
            exit 1
        fi
    fi
fi

# update OPENREFINE_URL env
OPENREFINE_URL="http://localhost:${args[--port]}"

# locate orcli and OpenRefine
if ! command -v orcli &>/dev/null; then
    if [[ -x "$0" ]]; then
        orcli="$0"
    else
        error "orcli is not executable!" "Try: chmod + $0"
    fi
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

# execute script(s) in subshell
export orcli tmpdir OPENREFINE_URL openrefine_pid
if [[ ${args[file]} == '-' || ${args[file]} == '"-"' ]]; then
    if ! read -u 0 -t 0; then
        # case 1: interactive mode if stdin is selected but not present
        bash --rcfile <(
            cat ~/.bashrc
            interactive
        ) -i </dev/tty
        exit
    fi
fi
if [[ ${args[--interactive]} ]]; then
    # case 2: execute scripts and keep shell running
    bash --rcfile <(
        cat ~/.bashrc
        for i in "${!files[@]}"; do
            log "execute script ${files[$i]}"
            awk 1 "${files[$i]}"
        done
        interactive
    ) -i </dev/tty
else
    # case 3: just execute scripts
    for i in "${!files[@]}"; do
        log "execute script ${files[$i]}"
        bash -e <(awk 1 "${files[$i]}")
    done
fi
