# orcli delete

```
orcli delete - delete OpenRefine project

Usage:
  orcli delete PROJECT [OPTIONS]
  orcli delete --help | -h

Options:
  --force, -f
    delete all projects with the same name

  --quiet, -q
    suppress log output, print errors only

  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

Examples:
  orcli delete "duplicates"
  orcli delete "duplicates" --force
  orcli delete 1234567890123
  for p in $(orcli list); do orcli delete ${p:0:13}; done

```

code: [src/commands/delete.sh](../src/commands/delete.sh)
