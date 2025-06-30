# orcli transform

```
orcli transform - apply undo/redo JSON file(s) to an OpenRefine project

Usage:
  orcli transform PROJECT [FILE...] [OPTIONS]
  orcli transform --help | -h

Options:
  --quiet, -q
    suppress log output, print errors only

  --help, -h
    Show this help

Arguments:
  PROJECT
    project name or id

  FILE...
    Path to one or more files or URLs. When FILE is -, read standard input.
    Default: -

Examples:
  orcli transform "duplicates" "history.json"
  cat "history.json" | orcli transform "duplicates"
  orcli transform "duplicates" "https://git.io/fj5ju"
  orcli transform 1234567890123 "history.json"

```

code: [src/commands/transform.sh](../src/commands/transform.sh)
