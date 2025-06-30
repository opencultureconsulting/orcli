# orcli export csv

```
orcli export csv - export comma-separated values (CSV)

Usage:
  orcli export csv PROJECT [OPTIONS]
  orcli export csv --help | -h

Options:
  --separator SEPARATOR
    character(s) that separates columns
    Default: ,

  --select COLUMNS
    filter result set to one or more columns (comma separated)
    example: --select "foo,bar,baz"

  --mode MODE
    specify if project contains multi-row records
    Allowed: rows, records
    Default: rows

  --facets FACETS
    filter result set by providing an OpenRefine facets config in json
    Default: []

  --output FILE
    Write to file instead of stdout

  --encoding ENCODING
    set character encoding
    Default: UTF-8

  --quiet, -q
    suppress log output, print errors only

  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

Examples:
  orcli export csv "duplicates"
  orcli export csv "duplicates" --output "duplicates.tsv"
  orcli export csv "duplicates" --separator ";"
  orcli export csv "duplicates" --encoding "ISO-8859-1"
  orcli export csv "duplicates" --select "name,email,purchase"
  orcli export csv "duplicates" --facets '[ { "type": "text", "columnName":
  "name", "mode": "regex", "caseSensitive": false, "invert": false, "query":
  "^Ben" } ]'
  orcli export csv "duplicates" --facets '[{ "type": "list", "expression":
  "grel:filter([\"gender\",\"purchase\"],cn,cells[cn].value.find(/^F/).length()>0).length()>0",
  "columnName": "", "selection": [{"v": {"v": true}}] }]'

```

code: [src/commands/export/csv.sh](../src/commands/export/csv.sh)
