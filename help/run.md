# orcli run

```
orcli run - run tmp OpenRefine workspace and execute shell script(s)

Usage:
  orcli run [FILE...] [OPTIONS]
  orcli run --help | -h

Options:
  --memory RAM
    maximum RAM for OpenRefine java heap space
    Default: 2048M

  --port PORT
    PORT on which OpenRefine should listen
    Default: 3333

  --interactive
    do not exit on error and keep bash shell open

  --quiet, -q
    suppress log output, print errors only

  --help, -h
    Show this help

Arguments:
  FILE...
    Path to one or more files or URLs. When FILE is -, read standard input.
    Default: -

Examples:
  orcli run --interactive
  orcli run << EOF
  orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
  orcli transform "duplicates" "https://git.io/fj5ju"
  orcli export tsv "duplicates"
EOF
  orcli run --memory "2000M" --port "3334" << EOF
  orcli import csv "https://git.io/fj5hF" --projectName "duplicates" &
  orcli import csv "https://git.io/fj5hF" --projectName "copy" &
  wait
  echo "finished import"
  orcli export csv "duplicates" --output duplicates.csv &
  orcli export tsv "duplicates" --output duplicates.tsv &
  wait
  wc duplicates*
EOF
  orcli run --interactive "file1.sh" "file2.sh" - << EOF
  echo "finished in $SECONDS seconds"
EOF

```

code: [src/run_command.sh](../src/run_command.sh)
