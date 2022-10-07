# shellcheck shell=bash
function interactive() {
    cat <<'EOF'
if ! command -v orcli &>/dev/null; then
    alias orcli="$orcli"
fi
PS1="(orcli) [\u@\h \W]\$ "
source <(orcli completions)
echo '================================================================'
echo 'Interactive Bash shell with OpenRefine running in the background'
echo 'Use the "orcli" command and tab completion to control OpenRefine'
echo 'Type "history -a FILE" to write out your session history'
echo 'Type "exit" or CTRL-D to destroy temporary OpenRefine workspace'
echo '================================================================'
EOF
}
