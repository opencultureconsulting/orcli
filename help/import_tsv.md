# orcli import tsv

```
orcli import tsv - import tab-separated values (TSV)

Usage:
  orcli import tsv [FILE...] [OPTIONS]
  orcli import tsv --help | -h

Options:
  --blankCellsAsStrings
    store blank cells as empty strings instead of nulls

  --columnNames COLUMNNAMES
    set column names (comma separated)
    hint: add --ignoreLines 1 to overwrite existing header row

  --encoding ENCODING
    set character encoding

  --guessCellValueTypes
    attempt to parse cell text into numbers

  --headerLines HEADERLINES
    parse x line(s) as column headers
    Default: 1

  --ignoreLines IGNORELINES
    ignore first x line(s) at beginning of file
    Default: -1

  --ignoreQuoteCharacter
    do not use any quote character to enclose cells containing column separators

  --includeFileSources
    add column with file source

  --includeArchiveFileName
    add column with archive file name

  --limit LIMIT
    load at most x row(s) of data
    Default: -1

  --quoteCharacter QUOTECHARACTER
    quote character to enclose cells containing column separators
    Default: "

  --skipBlankRows
    do not store blank rows

  --skipDataLines SKIPDATALINES
    discard initial x row(s) of data
    Default: 0

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
  orcli import tsv "file"
  orcli import tsv "file1" "file2"
  head -n 100 "file" | orcli import tsv
  orcli import tsv "https://example.com/file.tsv"
  orcli import tsv "file" \
    --separator ";" \
    --columnNames "foo,bar,baz" \
    --ignoreLines 1 \
    --encoding "ISO-8859-1" \
    --limit 100 \
    --trimStrings \
    --projectName "duplicates" \
    --projectTags "test,urgent"

```

code: [src/import_tsv_command.sh](../src/import_tsv_command.sh)
