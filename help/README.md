# orcli 0.1.0

## command help screens

- [completions](completions.md)
- [delete](delete.md)
- [export template](export_template.md)
- [export tsv](export_tsv.md)
- [import csv](import_csv.md)
- [import tsv](import_tsv.md)
- [info](info.md)
- [list](list.md)
- [run](run.md)
- [test](test.md)
- [transform](transform.md)

## main help screen

```
orcli - OpenRefine command-line interface written in Bash

Usage:
  orcli COMMAND
  orcli [COMMAND] --help | -h
  orcli --version | -v

Commands:
  completions   Generate bash completions
  delete        delete OpenRefine project
  import        commands to create OpenRefine projects from files or URLs
  list          list projects on OpenRefine server
  info          show OpenRefine project's metadata
  test          run functional tests on tmp OpenRefine workspace
  transform     apply undo/redo JSON file(s) to an OpenRefine project
  export        commands to export data from OpenRefine projects to files
  run           run tmp OpenRefine workspace and execute shell script(s)

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number

Environment Variables:
  OPENREFINE_URL
    URL to OpenRefine server
    Default: http://localhost:3333

Examples:
  orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
  orcli list
  orcli info "duplicates"
  orcli transform "duplicates" "https://git.io/fj5ju"
  orcli export tsv "duplicates"
  orcli export tsv "duplicates" --output "duplicates.tsv"
  orcli delete "duplicates"
  orcli run --interactive
  orcli run << EOF
    orcli import csv "https://git.io/fj5hF" --projectName "duplicates"
    orcli transform "duplicates" "https://git.io/fj5ju"
    orcli export tsv "duplicates"
  EOF

https://github.com/opencultureconsulting/orcli

```