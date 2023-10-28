# orcli export tsv

```
orcli export tsv - export tab-separated values (TSV)

Usage:
  orcli export tsv PROJECT [OPTIONS]
  orcli export tsv --help | -h

Options:
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
  orcli export tsv "duplicates"
  orcli export tsv "duplicates" --output "duplicates.tsv"
  orcli export tsv "duplicates" --encoding "ISO-8859-1"
  orcli export tsv "duplicates" --facets '[ { "type": "text", "columnName":
  "name", "mode": "regex", "caseSensitive": false, "query": "^Ben" } ]'
  orcli export tsv "duplicates" --facets '[{ "type": "list", "expression":
  "grel:filter([\"gender\",\"purchase\"],cn,cells[cn].value.find(/^F/).length()>0).length()>0",
  "columnName": "", "selection": [{"v": {"v": true}}] }]'

```

code: [src/export_tsv_command.sh](../src/export_tsv_command.sh)
