# shellcheck shell=bash disable=SC2154 source=/dev/null

# catch args, convert the space delimited string to an array
files=()
eval "files=(${args[file]})"

# check existence of files and stdin
for i in "${!files[@]}"; do
    if [[ "${files[$i]}" == '-' ]] || [[ "${files[$i]}" == '"-"' ]]; then
        # exit if stdin is selected but not present
        if ! [[ ${args[--interactive]} ]]; then
            require_stdin
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

# start OpenRefine with tmp workspace
start_openrefine

# execute script(s) in subshell
if [[ ${args[file]} == '-' || ${args[file]} == '"-"' ]]; then
    if ! read -u 0 -t 0; then
        sleep 1
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
