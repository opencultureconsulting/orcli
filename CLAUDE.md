# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`orcli` is a Bash CLI that controls [OpenRefine](https://openrefine.org) through its HTTP API (`curl` + `jq`, Bash 4.2+). It targets the latest OpenRefine release (currently 3.10). It is meant to be dropped into the OpenRefine program directory, next to OpenRefine's `refine` startup script.

## Build system: bashly

The top-level `orcli` file is **generated** by [bashly](https://bashly.dev) from `src/` and committed to the repo. Never edit `orcli` by hand; edit `src/` and regenerate:

```sh
gem install bashly          # once (requires ruby)
bashly generate --upgrade   # regenerate ./orcli from src/
```

- `src/bashly.yml` defines every command, arg, flag, default, conflict and example (and the version number). Flags/args shared between commands are defined once with YAML anchors (`&file`, `&project`, `&quiet`, `&separator`, …) and reused with aliases (`*file`) — reuse them when adding commands.
- `src/<command>_command.sh` holds each command's body; nested commands use underscores (`import csv` → `import_csv_command.sh`). bashly exposes parsed input via the `args` associative array (`${args[--flag]}`, `${args[file]}`).
- `src/lib/*.sh` are shared functions bashly inlines into the script: `error`/`log` (stderr logging, honors `--quiet` and `ORCLI_QUIET`; `error` also prints the tail of OpenRefine's log when running inside `orcli run`), `get_csrf`, `get_id`/`get_ids` (resolve project name or 13-digit id), `init_import` + `post_import` (shared import pipeline), `post_export` (shared export pipeline with `--facets`/`--mode`/`--output`), `interactive`, `send_completions`.
- `src/initialize.sh` runs before every command.

After changing commands or help text, also regenerate the docs:

```sh
./help.sh                                  # writes help/*.md from --help screens
bashly render templates/html-form docs     # writes docs/*.html (published HTML form docs)
```

Releases bump `version:` in `src/bashly.yml`, then regenerate `orcli` and `docs/`.

## Architecture notes

- **Imports** (`import_*_command.sh`): call `init_import` (downloads http(s) URLs and `/dev/fd` pipes into a tmp dir; zips multiple files into `Untitled.zip` so OpenRefine treats them as one archive), build format-specific `options` JSON, then `post_import` posts to `create-project-from-upload` and validates the resulting project id / row count. Only CSV, TSV, TXT (fixed-width), JSON, JSONL are implemented. `import txt` uses OpenRefine's fixed-width importer; without `--columnWidths` every line becomes one single-column row. Note that in this importer `ignoreLines` also skips the injected `--columnNames` row, so `--skipDataLines 1` is the way to replace an existing header.
- **Exports** (`export_*_command.sh`): build `format`/options and call `post_export`, which posts to `export-rows`. `export template` uses OpenRefine's templating exporter.
- **Transform** (`transform_command.sh`): does not use OpenRefine's `apply-operations`. It splits an undo/redo history JSON into individual operations and maps each `op` name to its specific command endpoint (see the mapping list in the file, derived from OpenRefine's `controller.js`) for better error handling and logging. New/renamed OpenRefine operations need a mapping entry there.
- **`run`** (`run_command.sh`): starts OpenRefine (`refine -d <tmpdir> -x refine.headless=true`) with a throwaway workspace on `--port` (default 3333, `--memory` default 2048M), waits for `get-version`, then runs the given bash script(s) with `alias orcli=<path>` in a `bash -e` subshell, or opens an interactive shell. A trap kills OpenRefine and removes the tmp workspace on exit.
- All other commands talk to an already-running OpenRefine at `OPENREFINE_URL` (default `http://localhost:3333`).

## Tests

```sh
./orcli test
```

Requires OpenRefine's `refine` script in the same directory as `orcli` and nothing else listening on port 3333. OpenRefine is extracted into the repo root (`refine`, `server`, `webapp`, `refine.ini` are gitignored) by:
- `.claude/hooks/session-start.sh` in Claude Code cloud sessions — also installs the bashly version that generated `./orcli`, puts it on `PATH` and sets a UTF-8 locale (`import-csv-unicode.sh` fails under `POSIX`). Bump `OPENREFINE_VERSION` there and in `.devcontainer/devcontainer.json` together.
- `.devcontainer/devcontainer.json` in Codespaces/devcontainers.

`test` starts OpenRefine with a tmp workspace (same mechanism as `run`) and executes every `tests/*.sh` from inside `tests/`, printing PASSED/FAILED per file. There is no built-in single-test option; to run one test, run that file through `run` from inside `tests/`, e.g. `cd tests && ../orcli run import-csv.sh`.

Test convention (one file per command/flag, named `<command>-<flag>.sh`): copy input and expected output from `tests/data/` into a `mktemp -d` dir, run `orcli` commands there, and finish with `diff -u "${t}.assert" "${t}.output"` — the diff's exit code is the test result. Keep test input in `tests/data/` rather than remote URLs: when `orcli` is used standalone (without the repo), `test` downloads the repo's `main.zip` and extracts only `tests/*.sh` and `tests/data/*`, so tests must reference data via the relative `data/` path. `transform.sh` deliberately imports from a `raw.githubusercontent.com` URL to cover URL import and needs network access.
