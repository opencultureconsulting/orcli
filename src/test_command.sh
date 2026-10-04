# shellcheck shell=bash disable=SC2154

# start OpenRefine with tmp workspace
start_openrefine

# download the test files if needed
if ! [[ -f "tests/help.sh" ]]; then
    cd "$OPENREFINE_TMPDIR"
    if ! curl -fs -L -o orcli.zip https://github.com/opencultureconsulting/orcli/archive/refs/heads/main.zip; then
        error "downloading test files failed!" "Please download the tests dir manually from GitHub."
    fi
    unzip -q -j orcli.zip "*/tests/*.sh" -d "tests/"
    unzip -q -j orcli.zip "*/tests/data/*" -d "tests/data/"
fi

# execute tests in subshell
cd "tests"
files=(*.sh)
results=()
for i in "${!files[@]}"; do
    set +e # do not exit on failed tests
    bash -e <(
        echo "shopt -s expand_aliases"
        echo "alias orcli=${scriptpath}/orcli"
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
