# orcli import txt

```
orcli import txt

  import text files (TXT), line-based or with fixed-width columns
  line-based (default): each line (or --linesPerRow lines) becomes a row
  fixed-width: split lines into columns by --columnWidths

Usage:
  orcli import txt [FILE...] [OPTIONS]
  orcli import txt --help | -h

Options:
  --blankCellsAsStrings
    store blank cells as empty strings instead of nulls

  --columnNames COLUMNNAMES
    set column names (comma separated)
    hint: add --ignoreLines 1 to overwrite existing header row
    Conflicts: --headerLines

  --columnWidths COLUMNWIDTHS
    split lines into columns of x characters (comma separated)
    text exceeding the sum of all widths is put in an extra column
    Conflicts: --linesPerRow

  --encoding ENCODING
    set character encoding

  --guessCellValueTypes
    attempt to parse cell text into numbers

  --headerLines HEADERLINES
    parse x line(s) as column headers
    default: 1 (fixed-width only, line-based import has no header lines)
    Needs: --columnWidths
    Conflicts: --columnNames

  --ignoreLines IGNORELINES
    ignore first x line(s) at beginning of file
    Default: -1

  --includeFileSources
    add column with file source

  --includeArchiveFileName
    add column with archive file name

  --limit LIMIT
    load at most x row(s) of data
    Default: -1

  --linesPerRow LINESPERROW
    number of lines that make up one row (line-based only)
    Default: 1
    Conflicts: --columnWidths

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
  orcli import txt "file"
  orcli import txt "file1" "file2"
  head -n 100 "file" | orcli import txt
  orcli import txt "https://example.com/file.txt"
  orcli import txt "file" --linesPerRow 3 --columnNames "foo,bar,baz"
  orcli import txt "file" --columnWidths "7,5"
  orcli import txt "file" \
    --columnWidths "7,5" \
    --columnNames "foo,bar,baz" \
    --ignoreLines 1 \
    --encoding "ISO-8859-1" \
    --limit 100 \
    --trimStrings \
    --projectName "duplicates" \
    --projectTags "test,urgent"

```

code: [src/import_txt_command.sh](../src/import_txt_command.sh)
