# orcli export template

```
orcli export template - export to any text format by providing your own GREL template

Usage:
  orcli export template PROJECT [FILE] [OPTIONS]
  orcli export template --help | -h

Options:
  --separator SEPARATOR
    insert character(s) between rows/records

  --prefix PREFIX
    insert character(s) at the beginning of the file

  --suffix SUFFIX
    insert character(s) at the end of the file

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

  FILE
    Path to row/record template file or URL. When FILE is -, read standard
    input.
    Default: -

Examples:
  orcli export template "duplicates" "template.txt"
  cat "template.txt" | orcli export template "duplicates"
  orcli export template "duplicates" "https://example.com/template.txt"
  orcli export template "duplicates" "template.txt" --output "duplicates.tsv"
  orcli export template "duplicates" \
    <<< '{ "name" : {{jsonize(cells["name"].value)}}, "purchase" :
  {{jsonize(cells["purchase"].value)}} }' \
    --prefix '{ "events" : [' \
    --separator , \
    --mode records \
    --suffix ]}$'\n' \
    --facets '[ { "type": "text", "columnName": "name", "mode": "regex",
  "caseSensitive": false, "invert": false, "query": "^Ben" } ]' \
    | jq

```

code: [src/export_template_command.sh](../src/export_template_command.sh)
