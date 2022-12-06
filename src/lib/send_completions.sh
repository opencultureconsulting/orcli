## [@bashly-upgrade completions send_completions]
send_completions() {
  echo $'# orcli completion                                         -*- shell-script -*-'
  echo $''
  echo $'# This bash completions script was generated by'
  echo $'# completely (https://github.com/dannyben/completely)'
  echo $'# Modifying it manually is not recommended'
  echo $''
  echo $'_orcli_completions_filter() {'
  echo $'  local words="$1"'
  echo $'  local cur=${COMP_WORDS[COMP_CWORD]}'
  echo $'  local result=()'
  echo $''
  echo $'  if [[ "${cur:0:1}" == "-" ]]; then'
  echo $'    echo "$words"'
  echo $'  '
  echo $'  else'
  echo $'    for word in $words; do'
  echo $'      [[ "${word:0:1}" != "-" ]] && result+=("$word")'
  echo $'    done'
  echo $''
  echo $'    echo "${result[*]}"'
  echo $''
  echo $'  fi'
  echo $'}'
  echo $''
  echo $'_orcli_completions() {'
  echo $'  local cur=${COMP_WORDS[COMP_CWORD]}'
  echo $'  local compwords=("${COMP_WORDS[@]:1:$COMP_CWORD-1}")'
  echo $'  local compline="${compwords[*]}"'
  echo $''
  echo $'  case "$compline" in'
  echo $'    \'completions\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'import csv\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--encoding --help --projectName --quiet --separator --trimStrings -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'import tsv\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--encoding --help --projectName --quiet --trimStrings -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'export tsv\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--encoding --help --output --quiet -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'transform\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help --quiet -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'delete\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help --quiet -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'import\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h csv tsv")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'export\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h tsv")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'list\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'info\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'test\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help -h")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    \'run\'*)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help --interactive --memory --port --quiet -h -q")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'    *)'
  echo $'      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_orcli_completions_filter "--help --version -h -v completions delete export import info list run test transform")" -- "$cur" )'
  echo $'      ;;'
  echo $''
  echo $'  esac'
  echo $'} &&'
  echo $'complete -F _orcli_completions orcli'
  echo $''
  echo $'# ex: filetype=sh'
}