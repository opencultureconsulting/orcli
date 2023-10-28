# orcli search

```
orcli search

  apply regex to each column and print matches in flattened tsv format
  output: index	column	value
  note that any exporter supports search by using --facets (see examples)

Usage:
  orcli search PROJECT [REGEX] [OPTIONS]
  orcli search --help | -h

Options:
  --index COLUMN
    print column values instead of row.index in the first column of the output

  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

  REGEX
    search term (regular expression, case-sensitive)

Examples:
  orcli search "duplicates" "^Ben"
  orcli search 1234567890123 "^Ben"
  orcli search "duplicates" "^F" --index "email"
  orcli search "duplicates" | column -t -s $'	'
  orcli export tsv "duplicates" --facets '[{ "type": "list", "expression":
  "grel:filter(row.columnNames,cn,cells[cn].value.find(/^Ben/).length()>0).length()>0",
  "columnName": "", "selection": [{"v": {"v": true}}] }]'
  orcli export tsv "duplicates" --facets '[{ "type": "list", "expression":
  "grel:filter([\"gender\",\"purchase\"],cn,cells[cn].value.find(/^F/).length()>0).length()>0",
  "columnName": "", "selection": [{"v": {"v": true}}] }]'

```

code: [src/search_command.sh](../src/search_command.sh)
