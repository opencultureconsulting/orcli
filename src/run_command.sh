# shellcheck shell=bash disable=SC2154 source=/dev/null

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# check existence of files and stdin
for i in "${!files[@]}"; do
    if [[ "${files[$i]}" == '-' ]] || [[ "${files[$i]}" == '"-"' ]]; then
        # exit if stdin is selected but not present
        if ! [[ ${args[--interactive]} ]]; then
            if ! read -u 0 -t 0; then
                orcli_run_usage
                exit 1
            fi
        fi
    else
        # exit if file does not exist
        if ! [[ -f "${files[$i]}" ]]; then
            error "cannot open ${files[$i]} (no such file)!"
        fi
    fi
done

# assume that quiet flag shall suppress log output generally in batch mode
if [[ ${args[--quiet]} ]]; then
    export ORCLI_QUIET=1
fi

# update OPENREFINE_URL env
OPENREFINE_URL="http://localhost:${args[--port]}"

# locate orcli and OpenRefine
scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
if [[ -x "${scriptpath}/refine" ]]; then
    openrefine="${scriptpath}/refine"
else
    error "OpenRefine's startup script (refine) not found!" "Did you put orcli in your OpenRefine app dir?"
fi

# check if OpenRefine is already running
if curl -fs "${OPENREFINE_URL}" &>/dev/null; then
    error "OpenRefine is already running on port ${args[--port]}." "Hint: Stop the other process or use another port."
fi

# create tmp directory
OPENREFINE_TMPDIR="$(mktemp -d)"
trap '{ rm -rf "$OPENREFINE_TMPDIR"; }' 0 2 3 15

# start OpenRefine with tmp workspace and autosave period 25 hours
REFINE_AUTOSAVE_PERIOD=1440 $openrefine -d "$OPENREFINE_TMPDIR" -m "${args[--memory]}" -p "${args[--port]}" -x refine.headless=true -v warn &>"$OPENREFINE_TMPDIR/openrefine.log" &
OPENREFINE_PID="$!"

# update trap to kill OpenRefine on error or exit
trap '{ rm -rf "$OPENREFINE_TMPDIR"; rm -rf /tmp/jetty-127_0_0_1-${OPENREFINE_URL##*:}*; kill -9 "$OPENREFINE_PID"; }' 0 2 3 15

# wait until OpenRefine is running (timeout 20s)
for i in {1..20}; do
    sleep 1
    if curl -fs "${OPENREFINE_URL}/command/core/get-version" &>/dev/null; then
        log "started OpenRefine with tmp workspace ${OPENREFINE_TMPDIR}"
        break
    fi
    if [[ $i == 20 ]]; then
        error "starting OpenRefine server failed!"
    fi
done

# execute script(s) in subshell
export OPENREFINE_TMPDIR OPENREFINE_URL OPENREFINE_PID
if [[ ${args[file]} == '-' || ${args[file]} == '"-"' ]]; then
    if ! read -u 0 -t 0; then
        # case 1: interactive mode if stdin is selected but not present
        bash --rcfile <(
            cat ~/.bashrc
            echo "alias orcli=${scriptpath}/orcli"
            interactive
        ) -i </dev/tty
        exit
    fi
fi
if [[ ${args[--interactive]} ]]; then
    # case 2: execute scripts and keep shell running
    bash --rcfile <(
        cat ~/.bashrc
        echo "alias orcli=${scriptpath}/orcli"
        for i in "${!files[@]}"; do
            log "executing script ${files[$i]}..."
            awk 1 "${files[$i]}"
        done
        interactive
    ) -i </dev/tty
else
    # case 3: just execute scripts
    for i in "${!files[@]}"; do
        log "executing script ${files[$i]}..."
        bash -e <(
            echo "shopt -s expand_aliases"
            echo "alias orcli=${scriptpath}/orcli"
            awk 1 "${files[$i]}"
        )
    done
    # print stats
    log "used $(($(ps --no-headers -o rss -p "$OPENREFINE_PID") / 1024)) MB RAM and $(ps --no-headers -o cputime -p "$OPENREFINE_PID") CPU time"
fi
