# add "key": value (valid json) to the options of an import
# shellcheck shell=bash disable=SC2154
function option() {
  options+="${options:+, }\"$1\": $2"
}

# add options of flags shared by import commands (if the command has them)
function import_options() {
  if [[ ${args[--encoding]} ]]; then
    option encoding "$(json_string "${args[--encoding]}")"
  fi
  if [[ ${args[--blankCellsAsStrings]} ]]; then
    option storeBlankCellsAsNulls false
  fi
  if [[ ${args[--columnNames]} ]]; then
    option columnNames "$(json_array "${args[--columnNames]}")"
  fi
  if [[ ${args[--headerLines]} ]]; then
    option headerLines "${args[--headerLines]}"
  fi
  # importers (except line-based txt) apply ignoreLines after inserting the
  # column names, so skip the ignored lines as data lines instead
  local skipDataLines="${args[--skipDataLines]}"
  if [[ ${args[--columnNames]} ]] && ((args[--ignoreLines] > 0)) && [[ ${args[--columnWidths]} || ! ${args[--linesPerRow]} ]]; then
    skipDataLines=$((skipDataLines + args[--ignoreLines]))
  elif [[ ${args[--ignoreLines]} ]]; then
    option ignoreLines "${args[--ignoreLines]}"
  fi
  if [[ ${skipDataLines} ]]; then
    option skipDataLines "${skipDataLines}"
  fi
  if [[ ${args[--ignoreQuoteCharacter]} ]]; then
    option processQuotes false
  elif [[ ${args[--quoteCharacter]} ]]; then
    option quoteCharacter "$(json_string "${args[--quoteCharacter]}")"
  fi
  if [[ ${args[--includeFileSources]} ]]; then
    option includeFileSources true
  fi
  if [[ ${args[--includeArchiveFileName]} ]]; then
    option includeArchiveFileName true
  fi
  if [[ ${args[--limit]} ]]; then
    option limit "${args[--limit]}"
  fi
  if [[ ${args[--skipBlankRows]} ]]; then
    option storeBlankRows false
  fi
  if [[ ${args[--storeEmptyStrings]} ]]; then
    option storeEmptyStrings true
  fi
  if [[ ${args[--projectName]} ]]; then
    option projectName "$(json_string "${args[--projectName]}")"
  fi
  if [[ ${args[--projectTags]} ]]; then
    option projectTags "$(json_array "${args[--projectTags]}")"
  fi
  # always send booleans that tree importers (json) default to true if missing
  # (parse default of tabular importers is false)
  if [[ ${args[--guessCellValueTypes]} ]]; then
    option guessCellValueTypes true
  else
    option guessCellValueTypes false
  fi
  if [[ ${args[--trimStrings]} ]]; then
    option trimStrings true
  else
    option trimStrings false
  fi
}
