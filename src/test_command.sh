# shellcheck shell=bash disable=SC2154

# locate orcli and OpenRefine
scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
if [[ -x "${scriptpath}/refine" ]]; then
    openrefine="${scriptpath}/refine"
else
    error "OpenRefine's startup script (refine) not found!" "Did you put orcli in your OpenRefine app dir?"
fi

# check if OpenRefine is already running
if curl -fs "${OPENREFINE_URL}" &>/dev/null; then
    error "OpenRefine is already running on port 3333." "Please stop the other process."
fi

# create tmp directory
OPENREFINE_TMPDIR="$(mktemp -d)"
trap '{ rm -rf "$OPENREFINE_TMPDIR"; }' 0 2 3 15

# download the test files if needed
if ! [[ -f "tests/help.sh" ]]; then
    cd "$OPENREFINE_TMPDIR"
    if ! curl -fs -L -o orcli.zip https://github.com/opencultureconsulting/orcli/archive/refs/heads/main.zip; then
        error "downloading test files failed!" "Please download the tests dir manually from GitHub."
    fi
    unzip -q -j orcli.zip "*/tests/*.sh" -d "tests/"
    unzip -q -j orcli.zip "*/tests/data/*" -d "tests/data/"
fi

# start OpenRefine with tmp workspace
$openrefine -d "$OPENREFINE_TMPDIR" -x refine.headless=true -v warn &>"$OPENREFINE_TMPDIR/openrefine.log" &
OPENREFINE_PID="$!"

# update trap to kill OpenRefine on error or exit
trap '{ rm -rf "$OPENREFINE_TMPDIR"; rm -rf /tmp/jetty-127_0_0_1-3333*; kill -9 "$OPENREFINE_PID"; }' 0 2 3 15

# wait until OpenRefine is running (timeout 20s)
ready="n"
for i in {1..20}; do
    if curl -fs "${OPENREFINE_URL}/command/core/get-version" &>/dev/null; then
        ready="y"
        break
    else
        sleep 1
    fi
done
if [[ "$ready" == "y" ]]; then
    log "started OpenRefine with tmp workspace ${OPENREFINE_TMPDIR}"
else
    error "starting OpenRefine server failed!"
fi

# execute tests in subshell
export OPENREFINE_TMPDIR OPENREFINE_URL OPENREFINE_PID
cd "tests"
files=(*.sh)
results=()
for i in "${!files[@]}"; do
    set +e # do not exit on failed tests
    bash -e <(
        if ! command -v orcli &>/dev/null; then
            echo "shopt -s expand_aliases"
            echo "alias orcli=${scriptpath}/orcli"
        fi
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

# print overall result
if [[ "${results[*]}" =~ [1-9] ]]; then
    error "failed tests!"
else
    log "all tests passed!"
fi
