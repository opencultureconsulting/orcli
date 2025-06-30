# orcli import json

```
orcli import json - import JSON

Usage:
  orcli import json [FILE...] [OPTIONS]
  orcli import json --help | -h

Options:
  --recordPath JSON
    specify record path elements in JSON array
    Default: [ "_" , "_" ]

  --rename
    rename columns after import to remove record path fragments

  --guessCellValueTypes
    attempt to parse cell text into numbers

  --includeFileSources
    add column with file source

  --includeArchiveFileName
    add column with archive file name

  --limit LIMIT
    load at most x row(s) of data
    Default: -1

  --storeEmptyStrings
    preserve empty strings

  --trimStrings
    trim leading & trailing whitespace from strings

  --projectName PROJECTNAME
    set a name for the OpenRefine project

  --projectTags PROJECTTAGS
    set project tags (comma separated)

  --quiet, -q
    suppress log output, print errors only

  --help, -h
    Show this help

Arguments:
  FILE...
    Path to one or more files or URLs. When FILE is -, read standard input.
    Default: -

Examples:
  orcli import json "file"
  orcli import json "file1" "file2"
  orcli import json "https://example.com/file.json"
  orcli import json "file" \
    --recordPath '[ "_", "rows", "_" ]' \
    --rename \
    --storeEmptyStrings \
    --trimStrings \
    --projectName "duplicates" \
    --projectTags "test,urgent"

```

code: [src/commands/import/json.sh](../src/commands/import/json.sh)
