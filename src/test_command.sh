# shellcheck shell=bash disable=SC2154

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# check existence of files
for i in "${!files[@]}"; do
    if ! [[ -f "${files[$i]}" ]]; then
        error "cannot open ${files[$i]} (no such file)!"
    fi
done

# locate orcli and OpenRefine
scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
if [[ -x "${scriptpath}/refine" ]]; then
    openrefine="${scriptpath}/refine"
else
    error "OpenRefine's startup script (refine) not found!" "Did you put orcli in your OpenRefine app dir?"
fi

# create tmp directory
OPENREFINE_TMPDIR="$(mktemp -d)"
trap '{ rm -rf "$OPENREFINE_TMPDIR"; }' 0 2 3 15

# check if OpenRefine is already running
if curl -fs "${OPENREFINE_URL}" &>/dev/null; then
    error "OpenRefine is already running."
fi

# start OpenRefine with tmp workspace and autosave period 25 hours
REFINE_AUTOSAVE_PERIOD=1440 $openrefine -d "$OPENREFINE_TMPDIR" -x refine.headless=true -v warn &>"$OPENREFINE_TMPDIR/openrefine.log" &
OPENREFINE_PID="$!"

# update trap to kill OpenRefine on error or exit
trap '{ rm -rf "$OPENREFINE_TMPDIR"; kill -9 "$OPENREFINE_PID"; }' 0 2 3 15

# wait until OpenRefine is running (timeout 20s)
if ! curl -fs --retry 20 --retry-connrefused --retry-delay 1 "${OPENREFINE_URL}/command/core/get-version" &>/dev/null; then
    error "starting OpenRefine server failed!"
else
    log "started OpenRefine with tmp workspace ${OPENREFINE_TMPDIR}"
fi

# execute script(s) in subshell
export OPENREFINE_TMPDIR OPENREFINE_URL OPENREFINE_PID
results=()
for i in "${!files[@]}"; do
    set +e
    bash -e <(
        # support ./orcli
        if ! command -v orcli &>/dev/null; then
            echo "shopt -s expand_aliases"
            echo "alias orcli=${scriptpath}/orcli"
        fi
        # separate subdirectory for each test
        echo "mkdir -p ${OPENREFINE_TMPDIR}/${files[$i]}"
        echo "cd ${OPENREFINE_TMPDIR}/${files[$i]} || exit 1"
        # echo test file
        awk 1 "${files[$i]}"
    ) &>"$OPENREFINE_TMPDIR/test.log"
    results+=(${?})
    set -e
    if [[ "${results[$i]}" =~ [1-9] ]]; then
        cat "$OPENREFINE_TMPDIR/test.log"
        log "FAILED ${files[$i]} with exit code ${results[$i]}!"
    else
        log "PASSED ${files[$i]}"
    fi
done

# summary
if [[ "${results[*]}" =~ [1-9] ]]; then
    error "failed tests!"
else
    log "all tests passed!"
fi
