# start OpenRefine with tmp workspace in the background and wait until it is running
# shellcheck shell=bash disable=SC2154
function start_openrefine() {
    local i link
    # locate orcli and OpenRefine (resolve symlinks like readlink -f, which
    # macOS lacks before 12.3)
    scriptpath="${BASH_SOURCE[0]}"
    while [[ -L ${scriptpath} ]]; do
        link="$(readlink "${scriptpath}")"
        if [[ ${link} == /* ]]; then
            scriptpath="${link}"
        else
            scriptpath="$(dirname "${scriptpath}")/${link}"
        fi
    done
    scriptpath="$(cd "$(dirname "${scriptpath}")" && pwd -P)"
    if ! [[ -x "${scriptpath}/refine" ]]; then
        error "OpenRefine's startup script (refine) not found!" "Did you put orcli in your OpenRefine app dir?"
    fi
    # check if OpenRefine is already running
    OPENREFINE_URL="http://localhost:${args[--port]}"
    if curl -fs "${OPENREFINE_URL}" &>/dev/null; then
        error "OpenRefine is already running on port ${args[--port]}." "Hint: Stop the other process or use another port."
    fi
    # create tmp directory
    OPENREFINE_TMPDIR="$(mktemp -d)"
    trap '{ rm -rf "$OPENREFINE_TMPDIR"; }' 0 2 3 15
    # start OpenRefine with tmp workspace and autosave period 25 hours
    REFINE_AUTOSAVE_PERIOD=1440 "${scriptpath}/refine" -d "$OPENREFINE_TMPDIR" ${args[--memory]:+-m "${args[--memory]}"} -p "${args[--port]}" -x refine.headless=true -v warn &>"$OPENREFINE_TMPDIR/openrefine.log" &
    OPENREFINE_PID="$!"
    disown "$OPENREFINE_PID" # no job status message when killed on exit
    # update trap to kill OpenRefine and remove Jetty's tmp dir on error or exit
    # (Java's tmp dir is /tmp on Linux and $TMPDIR on macOS)
    trap '{ kill -9 "$OPENREFINE_PID"; rm -rf "$OPENREFINE_TMPDIR" /tmp/jetty-127_0_0_1-"${OPENREFINE_URL##*:}"-* "${TMPDIR:-/tmp}"/jetty-127_0_0_1-"${OPENREFINE_URL##*:}"-*; }' 0 2 3 15
    export OPENREFINE_TMPDIR OPENREFINE_URL OPENREFINE_PID
    # wait until OpenRefine is running (fail early if it exits)
    for ((i = 0; i < args[--timeout] * 4; i++)); do
        if curl -fs "${OPENREFINE_URL}/command/core/get-version" &>/dev/null; then
            log "started OpenRefine with tmp workspace ${OPENREFINE_TMPDIR}"
            return
        fi
        if ! kill -0 "$OPENREFINE_PID" 2>/dev/null; then
            break
        fi
        sleep 0.25
    done
    error "starting OpenRefine server failed!"
}
