# orcli export jsonl

```
orcli export jsonl - export JSON Lines / newline-delimited JSON

Usage:
  orcli export jsonl PROJECT [OPTIONS]
  orcli export jsonl --help | -h

Options:
  --mode MODE
    specify if project contains multi-row records
    Allowed: rows, records
    Default: rows

  --separator SEPARATOR
    character(s) that separates multiple values in one cell (row mode only)

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
  orcli export jsonl "duplicates"
  orcli export jsonl "duplicates" --output "duplicates.jsonl"
  orcli export jsonl "duplicates" --separator ' '
  orcli export jsonl "duplicates" --mode records
  orcli export jsonl "duplicates" --facets '[ { "type": "text", "columnName":
  "name", "mode": "regex", "caseSensitive": false, "invert": false, "query":
  "^Ben" } ]'
  orcli export jsonl "duplicates" --facets '[{ "type": "list", "expression":
  "grel:filter([\"gender\",\"purchase\"],cn,cells[cn].value.find(/^F/).length()>0).length()>0",
  "columnName": "", "selection": [{"v": {"v": true}}] }]'

```

code: [src/export_jsonl_command.sh](../src/export_jsonl_command.sh)
