# orcli info

```
orcli info - show OpenRefine project's metadata

Usage:
  orcli info PROJECT
  orcli info --help | -h

Options:
  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

Examples:
  orcli info "duplicates"
  orcli info 1234567890123
  orcli info "duplicates" | jq -r .columns[]

```

code: [src/info_command.sh](../src/info_command.sh)
