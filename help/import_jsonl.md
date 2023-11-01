# orcli import jsonl

```
orcli import jsonl - import JSON Lines / newline-delimited JSON

Usage:
  orcli import jsonl [FILE...] [OPTIONS]
  orcli import jsonl --help | -h

Options:
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
  orcli import jsonl "file"
  orcli import jsonl "file1" "file2"
  orcli import jsonl "https://example.com/file.json"
  orcli import jsonl --rename <(orcli export jsonl "duplicates")
  orcli import jsonl "file" \
    --rename \
    --storeEmptyStrings \
    --trimStrings \
    --projectName "duplicates" \
    --projectTags "test,urgent"

```

code: [src/import_jsonl_command.sh](../src/import_jsonl_command.sh)
