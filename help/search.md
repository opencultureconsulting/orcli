# orcli search

```
orcli search - apply regex to each column and print matches in flattened tsv format

Usage:
  orcli search PROJECT [REGEX]
  orcli search --help | -h

Options:
  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

  REGEX
    search

Examples:
  orcli search "duplicates" "^Ben"
  orcli search 1234567890123 "^Ben"
  orcli search "duplicates" "^Ben" | column -t -s $'	'

```

code: [src/search_command.sh](../src/search_command.sh)
