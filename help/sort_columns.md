# orcli sort columns

```
orcli sort columns - re-order columns alphabetically

Usage:
  orcli sort columns PROJECT [OPTIONS]
  orcli sort columns --help | -h

Options:
  --first COLUMN (repeatable)
    set key column(s)

  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

Examples:
  orcli sort columns "duplicates"
  orcli sort columns "duplicates" --first name

```

code: [src/commands/sort/columns.sh](../src/commands/sort/columns.sh)
